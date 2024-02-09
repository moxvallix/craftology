class CraftNewElementJob < ApplicationJob
  require 'net/http'
  require 'uri'

  include Craftology::Env

  PROMPT_TEMPLATE = File.read("lib/assets/prompt.txt").freeze
  SCHEDULE_FAILURE_RETRY = 10.minutes
  SCHEDULE_PENDING_RETRY = 1.hour

  queue_as :default

  def self.allow_schedule?(recipe)
    return true if recipe.status_scheduled?
    difference = Time.current - recipe.updated_at
    return true if recipe.status_failed? && difference > SCHEDULE_FAILURE_RETRY
    return true if recipe.status_pending? && difference > SCHEDULE_PENDING_RETRY
    false
  end

  def perform(recipe)
    return false unless self.class.allow_schedule?(recipe)
    recipe.update(status: :pending)
    prompt_text = prompt(recipe.left_element.name, recipe.right_element.name)
    element_data = send_prompt(prompt_text)

    recipe.reload
    return false unless recipe.status_pending?

    raise "Missing result!" unless element_data[:result].is_a? String
    raise "Missing icon!" unless element_data[:emoji].is_a? String
    raise "Missing description!" unless element_data[:description].is_a? String

    set_recipe(recipe, element_data)
  rescue => e
    Rails.logger.error("Failed to craft recipe: " + e.message)
    recipe.update(status: :failed)
  end

  def set_recipe(recipe, data)
    params = {
      name: data[:result].to_s.tr("-", " ").downcase.strip.squeeze(" "),
      icon: data[:emoji].to_s[..2],
      description: data[:description],
      discovered_by: recipe.discovered_by,
      discovered_uuid: recipe.discovered_uuid
    }

    element = find_or_create_element(params)
    recipe.update(status: :active, result: element)
  end

  def find_or_create_element(params = {})
    element = Element.find_by_name(params[:name])
    return element if element.present?

    Element.create(params)
  end

  def prompt(left, right)
    PROMPT_TEMPLATE.gsub("%1", left).gsub("%2", right)
  end

  def send_prompt(prompt_text)
    service = find_value_by_name("llm", "service")
    case service
    when "llama" then return prompt_llama_cpp(prompt_text)
    when "togetherai" then return prompt_together_ai(prompt_text)
    end
  end
  
  private

  def process_response(output)
    content = output.split("\n").first
    JSON.parse(content).symbolize_keys
  end
  
  def prompt_llama_cpp(prompt_text)
    json = {
      stream: false,
      prompt: prompt_text
    }.to_json
    response = Net::HTTP.post(URI(find_value_by_name("llm", "endpoint")), json)
    response_json = JSON.parse(response.body)
    process_response(response_json["content"])
  end

  def prompt_together_ai(prompt_text, retries = 0)
    json = {
      model: "lmsys/vicuna-13b-v1.5",
      temperature: 0.8,
      top_p: 0.950,
      top_k: 40,
      max_tokens: 350,
      repetition_penalty: 1.1,
      prompt: prompt_text,
      stop: "\n"
    }.to_json
    headers = {
      "Authorization" => "Bearer #{find_value_by_name("togetherai", "token")}",
      "Content-Type" => "application/json"
    }
    response = Net::HTTP.post(
      URI(find_value_by_name("llm", "endpoint")), json, headers
    )
    if response.is_a?(Net::HTTPTooManyRequests) && retries < 5
      sleep 2
      prompt_together_ai(prompt_text, retries + 1)
    elsif response.is_a?(Net::HTTPOK)
      response_json = JSON.parse(response.body)
      output = response_json.dig("output", "choices", 0, "text")
      process_response(output)
    else
      raise "Error with Together.ai API"
    end
  end
end

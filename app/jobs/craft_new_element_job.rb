class CraftNewElementJob < ApplicationJob
  require 'net/http'
  require 'uri'

  PROMPT_TEMPLATE = File.read("lib/assets/prompt.txt").freeze
  LLAMA_ENDPOINT = URI("http://localhost:8080/completion")
  SCHEDULE_FAILURE_RETRY = 10.minutes
  SCHEDULE_PENDING_RETRY = 1.hour

  queue_as :default

  def perform(recipe)
    return false unless allow_schedule?(recipe)
    recipe.update(status: :pending)
    prompt_text = prompt(recipe.left_element.name, recipe.right_element.name)
    response = send_prompt(prompt_text)
    response_json = JSON.parse(response.body)
    
    begin
      content = response_json["content"].split("\n").first
      puts content
      element_data = JSON.parse(content).symbolize_keys
    end

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

  def allow_schedule?(recipe)
    return true if recipe.status_scheduled?
    difference = Time.current - recipe.updated_at
    return true if recipe.status_failed? && difference > SCHEDULE_FAILURE_RETRY
    return true if recipe.status_pending? && difference > SCHEDULE_PENDING_RETRY
    false
  end

  def set_recipe(recipe, data)
    params = {
      name: data[:result].to_s.downcase.strip.squeeze(" "),
      icon: data[:emoji].to_s[..1],
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

  def send_prompt(prompt)
    json = {
      stream: false,
      prompt: prompt
    }.to_json
    Net::HTTP.post(LLAMA_ENDPOINT, json)
  end
end

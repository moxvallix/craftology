class StaticController < ApplicationController
  def game
  end

  def challenge
    elements = Element.order_random.first(2)
    if current_user.present?
      start_elements = current_user.discovered_elements.order_random.first(4)
    else
      start_elements = Element.default
    end
    @emoji_target = elements[0] || Element.error
    @word_target = elements[1] || Element.error
    @start = Element.default_list start_elements
  end
end

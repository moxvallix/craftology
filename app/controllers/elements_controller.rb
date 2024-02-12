class ElementsController < ApplicationController
  before_action :set_element

  def show
    if current_user.present?
      @pagy, @recipes = pagy(current_user.recipes_for_element(@element), items: 5)
    end
  end

  private

  def set_element
    @element = Element.find(params[:element_id] || params[:id])

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end

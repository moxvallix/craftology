class ElementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_element
  before_action :check_user_discovered

  def show
    @pagy, @recipes = pagy(@element.recipes, items: 5)
  end

  private

  def set_element
    @element = Element.find(params[:element_id] || params[:id])

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def check_user_discovered
    return true if @element.user_discovered?(current_user)
    redirect_to root_path
  end
end

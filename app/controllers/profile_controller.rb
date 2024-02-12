class ProfileController < ApplicationController
  before_action :set_user, only: %i[show]
  rescue_from Pagy::OverflowError, with: :redirect_to_last_page
  

  def show
    @pagy, @discoveries = pagy(@user.discovered_elements(params[:filter]), items: 45)
  end

  private
  
  def set_user
    @user = User.find_by_name!(params[:profile_id] || params[:id])

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def redirect_to_last_page(exception)
    redirect_to url_for(page: exception.pagy.last)
  end
end

class ProfileController < ApplicationController
  before_action :set_user, only: %i[show]

  def show
    @pagy, @discoveries = pagy(@user.discovered_elements, items: 45)
  end

  private
  
  def set_user
    @user = User.find_by_name!(params[:profile_id] || params[:id])

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end

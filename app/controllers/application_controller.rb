class ApplicationController < ActionController::Base
  before_action :configure_devise_parameters, if: :devise_controller?

  def configure_devise_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name claim_id])
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[claim_id])
  end

  def after_sign_in_path_for(resource)
    puts resource.claim(params.dig(:user, :claim_id))
    return root_path
 end
end

class ApplicationController < ActionController::Base
  include Pundit
  before_action :configure_permitted_parameters, if: :devise_controller?

  around_action :set_time_zone, if: :current_user

  rescue_from ActionController::InvalidAuthenticityToken,
              with: :invalid_auth_token
  before_action :set_current_user, if: :json_request?

  private

  def json_request?
    request.format.json?
  end


  def invalid_auth_token
    respond_to do |format|
      format.html { redirect_to sign_in_path, error: 'Login invalid or expired' }
      format.json { head 401 }
    end
  end

  def after_sign_in_path_for(resource)
    if session[:user_return_to].present? and !Rails.configuration.ignored_paths.include?(session[:user_return_to])
      session[:user_return_to]
    else
      dashboard_path
    end
  end

  # So we can use Pundit policies for api_users
  def set_current_user
    @current_user ||= warden.authenticate(scope: :api_user)
  end

  def set_time_zone(&block)
    Time.use_zone(current_user.timezone, &block)
  end

  # configures the permitted parameters for devise (i.e. used on registration / sign up)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:settings, keys: [:timezone, :experimentation_email, :reflection_at_string, reflection_on: []])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username,:firstname,:lastname, :email, :study_agreement])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname,:lastname, :email, :password, :password_confirmation,:timezone, :reflection_at, reflection_on: []])
  end
end

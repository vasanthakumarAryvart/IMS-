class ApplicationController < ActionController::Base
  before_filter :set_headers

  protect_from_forgery with: :exception

  layout :layout_by_resource
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :devise_controller_setup, if: :devise_controller?
  before_filter :setup_variables
  before_filter {
    @top_menu = :user
  }
  before_filter :check_blocked
   def after_sign_in_path_for(user) 
  dashboard_path
  end

  def set_headers
    # puts "check_new headers"
    # headers['Access-Control-Allow-Origin'] = '*'
    # headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    # headers['Access-Control-Request-Method'] = '*'
    # headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    if request.headers["HTTP_ORIGIN"]     
      headers['Access-Control-Allow-Origin'] = request.headers["HTTP_ORIGIN"]
      headers['Access-Control-Expose-Headers'] = 'ETag'
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
      headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match,Auth-User-Token'
      headers['Access-Control-Max-Age'] = '86400'
      headers['Access-Control-Allow-Credentials'] = 'true'
    end
  end   

  protected

  def layout_by_resource
    if current_user
      "application"
    else
      "non_member"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :company_name, :phone_number, :image])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :company_name, :phone_number, :image])
    # devise_parameter_sanitizer.for(:sign_up) << User::EDITABLE_FIELDS
    # devise_parameter_sanitizer.permit(:account_update) << User::EDITABLE_FIELDS
  end

  def devise_controller_setup
    @top_menu_item = :settings if current_user
  end

  def require_admin!
    unless current_user.try(:is_admin?)
      flash[:alert] = "You cannot access this section"
      redirect_to '/'
    end
  end

  def setup_variables
    @body_classes = []
  end

  def check_blocked
    if current_user.try(:blocked?)
      sign_out current_user
      flash[:alert] = "Your account was blocked by the Administrator"
      redirect_to new_user_session_path
    end
  end
end

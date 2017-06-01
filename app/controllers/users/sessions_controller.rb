class Users::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  before_action :configure_sign_in_params, only: [:create]
  respond_to :html, :json
      require 'json'

  before_filter :set_headerss
  # before_filter :ensure_login_params_exist, only: :create

  def set_headerss
      puts '=====+++======.set_headers'

  puts "=========insidec_headers===========" 
headers['Access-Control-Allow-Origin'] = '*'
headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
headers['Access-Control-Request-Method'] = '*'
headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

 
  end
 def ensure_login_params_exist
    return if !params[:user][:email].blank? and !params[:user][:password].blank?
    render status: 422, json: { error: "Missing Login params"}
  end
  # GET /resource/sign_in
  def new
    super
        puts "=====inside==new======"

  end

  # POST /resource/sign_in
  def create
    super
    #  user = User.find_by_email(params[:user][:email])
    # return render status: 200, json: { error: "Invalid Credentials" } if user.blank?
    # return render status: 200, json: { error: "Please confirm your email address to continue" } unless user.confirmed?
    # if user &&  user.valid_password?(params[:user][:password])
    #   sign_in(:user, user)
    #   return render status: 200, json: user.as_json
    # end
    # return render status: 200, json: { error: "Invalid Credentials" }

  end
  # def create
  #       puts"====inside====user create========="

  #   @users = User.order('created_at DESC')

  #   user = User.find_by_email(params[:user][:email])
  #   return render status: 200, json: { error: "Invalid Credentials" } if user.blank?
  #   return render status: 200, json: { error: "Please confirm your email address to continue" } unless user.confirmed?
  #   if user &&  user.valid_password?(params[:user][:password])
  #         puts"====inside====idfffe========="

  #     sign_in(:user, user)
  #     return render status: 200, json: user.as_json
  #   end
  #   return render status: 200, json: { error: "Invalid Credentials" }
  #       puts"====inside====elseee========="

  # end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end

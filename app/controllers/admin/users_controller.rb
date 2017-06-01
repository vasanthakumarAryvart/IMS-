class Admin::UsersController < Admin::AdminController
  before_filter {
    @top_menu_item = :users
  }

  def index
    @users = User.order('created_at DESC')
  end

  def edit
    @user = User.find(params[:id])
    render :layout => false
  end

  def state
    user = User.find(params[:id])
    case params[:status]
      when 'admin'
        user.unblock!
        user.make_admin!
      when 'user'
        user.unblock!
        user.revoke_admin!
      when 'blocked'
        user.block!
      else
        render :text => 'Error', :status => :unprocessable_entity
        return
    end
    render :text => 'OK'
  end
end

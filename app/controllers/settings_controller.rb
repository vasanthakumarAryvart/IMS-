class SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter {
    @top_menu_item = :settings
  }

  def accounts

  end

  def notifications
    @notifications = current_user.notifications
  end

  def disconnect_account
    account = current_user.accounts.find(params[:id])
    if account
      account.disconnect_integration!
      flash[:notice] = 'Account disconnected'
    else
      flash[:alert] = 'Account not found'
    end
    redirect_to :connected_accounts
  end
end

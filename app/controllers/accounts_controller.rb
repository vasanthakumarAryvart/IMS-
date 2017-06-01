class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter {
    @top_menu_item = :settings
  }

  def update
    @account = current_user.accounts.find(params[:id])
    if @account
      if @account.update_attributes(params[:account].permit(:auto_renew, :relisting_pricing => [:unit, :operator, :value], :sale_events_attributes => [[:start_date, :end_date, :id, :discount_percent, :item_category_id, :_destroy]]))
        flash[:notice] = 'Account updated successfully'
      else
        flash[:alert] = 'Account could not be updated'
      end
    else
      flash[:alert] = 'Account not found'
    end
    redirect_to :connected_accounts
  end
end

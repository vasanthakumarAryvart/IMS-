class ChangeSaleEventsDateFieldsType < ActiveRecord::Migration
  def change
    change_column :sale_events, :start_date, :datetime
    change_column :sale_events, :end_date, :datetime
  end
end

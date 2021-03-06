class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :company_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :is_admin, :boolean
    add_attachment :users, :image
  end
end

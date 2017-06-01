class CreateBuyers < ActiveRecord::Migration
  def change
    create_table :buyers do |t|
      t.integer :account_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :uid

      t.timestamps
    end
  end
end

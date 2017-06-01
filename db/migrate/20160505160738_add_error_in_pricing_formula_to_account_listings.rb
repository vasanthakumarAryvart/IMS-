class AddErrorInPricingFormulaToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :error_in_pricing_formula, :string
  end
end

json.array!(@inventory_items) do |inventory_item|
  json.extract! inventory_item, :id, :icc,  :make, :model, :details, :status, :location, :acquisition_cost, :cached_profit_share_percent, :archived, :item_category
end

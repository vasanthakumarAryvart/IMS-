
json.array!(@warehouses) do |warehouse|
  json.extract! warehouse, :id, :title, :user_id, :address, :description
end

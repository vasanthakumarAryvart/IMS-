json.array!(@shipping_presets) do |shipping_preset|
  json.extract! shipping_preset, :id, :title,  :provider, :price, :description, :countries, :user_id
  # json.url product_url(product, format: :json)
end

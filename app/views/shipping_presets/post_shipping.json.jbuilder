json.array!(@shipping_presets) do |shipping_preset|
  json.extract! shipping_preset, :id, :title, :user_id, :provider, :price, :description, :countries
  # json.url product_url(product, format: :json)
end

json.array!(@listting) do |listt|
  json.extract! listt, :id, :user_id, :item_category_id, :shipping_preset_id
  # json.url  listings_path_url (listt, format: :json)
end
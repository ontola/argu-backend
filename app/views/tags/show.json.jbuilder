json.collection @collection[:collection] do |item|
  json.id item.id
  json.headline item.display_name
  json.created_at item.created_at
  json.updated_at item.updated_at
end
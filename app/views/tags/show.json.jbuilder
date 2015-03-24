json.collection @collection do |item|
  json.id item.id
  json.shortname item.title
  json.created_at item.created_at
  json.updated_at item.updated_at
end
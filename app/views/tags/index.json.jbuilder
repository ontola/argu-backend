# frozen_string_literal: true
json.tags @tags do |tag|
  json.name tag.name
  json.count tag.taggings_count
end

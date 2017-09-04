# frozen_string_literal: true

json.id authenticated_resource.id
json.title authenticated_resource.title
json.content authenticated_resource.content
json.score authenticated_resource.score
json.is_trashed authenticated_resource.is_trashed?
json.voted @voted.presence ? @voted : 'abstain'
json.created_at authenticated_resource.created_at
json.updated_at authenticated_resource.updated_at
json.arguments authenticated_resource.arguments do |a|
  json.id a.id
  json.pro a.pro
  json.title a.title
end

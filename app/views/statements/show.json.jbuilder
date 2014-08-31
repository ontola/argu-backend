json.id @statement.id
json.title @statement.title
json.content @statement.content
json.score @statement.score
json.is_trashed @statement.is_trashed
json.voted @voted.presence ? @voted : 'abstain'
json.arguments @statement.arguments do |a|
  json.id a.id
  json.title a.title
end
json.opinions @statement.opinions do |o|
  json.id o.id
  json.title o.title
end
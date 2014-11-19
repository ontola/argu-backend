json.id @motion.id
json.title @motion.title
json.content @motion.content
json.score @motion.score
json.is_trashed @motion.is_trashed
json.voted @voted.presence ? @voted : 'abstain'
json.arguments @motion.arguments do |a|
  json.id a.id
  json.pro a.pro
  json.title a.title
end
json.opinions @motion.opinions do |o|
  json.id o.id
  json.title o.title
end
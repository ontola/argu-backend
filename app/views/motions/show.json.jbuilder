# frozen_string_literal: true
json.id @motion.id
json.title @motion.title
json.content @motion.content
json.score @motion.score
json.is_trashed @motion.is_trashed
json.voted @voted.presence ? @voted : 'abstain'
json.created_at @motion.created_at
json.updated_at @motion.updated_at
json.arguments @motion.arguments do |a|
  json.id a.id
  json.pro a.pro
  json.title a.title
end

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
json.opinions @motion.opinions do |o|
  json.id o.id
  json.title o.title
end
json.group_responses @group_responses do |group, responses|
  json.collection responses[:collection].flat_map{ |k,v| v[:collection] } do |g_r|
    json.id g_r.id
    json.creator_url dual_profile_path(g_r.profile)
    json.text g_r.text
    json.side g_r.side
    json.created_at g_r.created_at
    json.updated_at g_r.updated_at
  end
  json.responses_left responses[:responses_left].to_s
 end

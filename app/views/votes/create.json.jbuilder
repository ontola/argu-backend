json.vote do
  json.object_type @model.class_name
  json.object_id @model.id
  json.current_vote (@vote && @vote.for || '')
  json.distribution do
    json.pro @model.try(:votes_pro_count)
    json.neutral @model.try(:votes_neutral_count)
    json.con @model.try(:votes_con_count)
  end
  json.percent do
    json.pro @model.try(:votes_pro_percentage)
    json.neutral @model.try(:votes_neutral_percentage)
    json.con @model.try(:votes_con_percentage)
  end
end
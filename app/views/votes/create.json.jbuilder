# frozen_string_literal: true
json.vote do
  json.objectType model.class_name
  json.objectId model.id
  json.currentVote vote&.for || ''
  json.distribution do
    json.pro model.children_count(:votes_pro)
    json.neutral model.children_count(:votes_neutral)
    json.con model.children_count(:votes_con)
  end
  json.percent do
    json.pro model.try(:votes_pro_percentage)
    json.neutral model.try(:votes_neutral_percentage)
    json.con model.try(:votes_con_percentage)
  end
end

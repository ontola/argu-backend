# frozen_string_literal: true

class VoteEventSerializer < EdgeSerializer
  extend UriTemplateHelper

  attribute :starts_at, predicate: NS::SCHEMA[:startDate]
  attribute :expires_at, predicate: NS::SCHEMA[:endDate]
  attribute :option_counts, unless: method(:export_scope?) do |object|
    {
      yes: object.children_count(:votes_pro),
      neutral: object.children_count(:votes_neutral),
      no: object.children_count(:votes_con)
    }
  end
  attribute :pro_count
  attribute :con_count
  attribute :neutral_count
  attribute :current_vote, predicate: NS::ARGU[:currentVote] do |object|
    current_vote_iri(object)
  end

  count_attribute :votes_pro
  count_attribute :votes_con
  count_attribute :votes_neutral

  with_collection :votes, predicate: NS::ARGU[:votes]
end

# frozen_string_literal: true

class VoteEventSerializer < BaseEdgeSerializer
  attribute :group_id
  attribute :starts_at, predicate: NS::SCHEMA[:startDate]
  attribute :ends_at, predicate: NS::SCHEMA[:endDate]
  attribute :result
  attribute :option_counts, unless: :export?
  attribute :pro_count
  attribute :con_count
  attribute :neutral_count
  link(:self) { object.iri if object.persisted? }

  def option_counts
    {
      yes: object.children_count(:votes_pro),
      neutral: object.children_count(:votes_neutral),
      no: object.children_count(:votes_con)
    }
  end

  with_collection :votes, predicate: NS::ARGU[:votes]

  def ends_at
    object.edge.expires_at
  end

  def vote_collection
    object.vote_collection(user_context: scope)
  end
end

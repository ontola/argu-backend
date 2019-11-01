# frozen_string_literal: true

class VoteEventSerializer < EdgeSerializer
  attribute :starts_at, predicate: NS::SCHEMA[:startDate]
  attribute :ends_at, predicate: NS::SCHEMA[:endDate]
  attribute :option_counts, unless: :export_scope?
  attribute :pro_count
  attribute :con_count
  attribute :neutral_count
  attribute :current_vote, predicate: NS::ARGU[:currentVote]
  link(:self) { object.iri if object.persisted? }

  with_collection :votes, predicate: NS::ARGU[:votes]

  def current_vote
    current_vote_iri(object)
  end

  def option_counts
    {
      yes: object.children_count(:votes_pro),
      neutral: object.children_count(:votes_neutral),
      no: object.children_count(:votes_con)
    }
  end

  def ends_at
    object.expires_at
  end
end

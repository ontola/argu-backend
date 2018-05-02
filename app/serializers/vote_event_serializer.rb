# frozen_string_literal: true

class VoteEventSerializer < EdgeableBaseSerializer
  attribute :group_id
  attribute :starts_at, predicate: NS::SCHEMA[:startDate]
  attribute :ends_at, predicate: NS::SCHEMA[:endDate]
  attribute :result
  attribute :option_counts, unless: :export_scope?
  attribute :pro_count
  attribute :con_count
  attribute :neutral_count
  link(:self) { object.iri if object.persisted? }

  has_one :current_vote,
          predicate: NS::ARGU[:currentVote],
          unless: :system_scope?

  with_collection :votes, predicate: NS::ARGU[:votes]

  def current_vote
    @vote ||= Edge
                .where_owner('Vote', creator: user_context.actor, primary: true)
                .find_by(parent: object.edge)
                &.owner
  end

  def option_counts
    {
      yes: object.children_count(:votes_pro),
      neutral: object.children_count(:votes_neutral),
      no: object.children_count(:votes_con)
    }
  end

  def ends_at
    object.edge.expires_at
  end
end

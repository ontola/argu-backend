# frozen_string_literal: true

class VoteEventSerializer < EdgeSerializer
  attribute :starts_at, predicate: NS::SCHEMA[:startDate]
  attribute :ends_at, predicate: NS::SCHEMA[:endDate]
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
                .where_owner('Vote', creator: user_context.actor, primary: true, root_id: object.root_id)
                .find_by(parent: object)
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

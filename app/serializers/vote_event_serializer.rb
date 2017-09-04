# frozen_string_literal: true

class VoteEventSerializer < BaseEdgeSerializer
  attributes :group_id, :starts_at, :ends_at, :result, :option_counts
  link(:self) { object.context_id if object.persisted? }

  def option_counts
    {
      yes: object.children_count(:votes_pro),
      neutral: object.children_count(:votes_neutral),
      no: object.children_count(:votes_con)
    }
  end

  has_one :vote_collection do
    link(:self) do
      {
        href: "#{object.context_id}/votes",
        meta: {
          '@type': 'argu:votes'
        }
      }
    end
    link(:related) do
      {
        href: "#{object.context_id}/votes",
        meta: {
          '@type': 'argu:VoteCollection'
        }
      }
    end
  end

  def ends_at
    object.edge.expires_at
  end

  def vote_collection
    object.vote_collection(user_context: scope)
  end
end

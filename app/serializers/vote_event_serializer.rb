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
        href: "#{object.class.try(:context_id_factory)&.call(object)}/votes",
        meta: {
          '@type': 'argu:votes'
        }
      }
    end
    link(:related) do
      {
        href: "#{object.class.try(:context_id_factory)&.call(object)}/votes",
        meta: {
          '@type': 'argu:VoteCollection'
        }
      }
    end
  end
end

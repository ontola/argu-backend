# frozen_string_literal: true
module Voteable
  extend ActiveSupport::Concern
  include PragmaticContext::Contextualizable

  included do
    contextualize :votes_pro_count, as: 'http://schema.org/upvoteCount'
    contextualize :votes_neutral_count, as: 'http://schema.org/abstainvoteCount'
    contextualize :votes_con_count, as: 'http://schema.org/downvoteCount'

    has_many :votes, as: :voteable, dependent: :destroy

    def total_vote_count
      children_count(:votes_pro).abs + children_count(:votes_con).abs + children_count(:votes_neutral).abs
    end

    def votes_pro_percentage
      vote_percentage children_count(:votes_pro)
    end

    def votes_neutral_percentage
      vote_percentage children_count(:votes_neutral)
    end

    def votes_con_percentage
      vote_percentage children_count(:votes_con)
    end

    def vote_percentage(vote_count)
      if vote_count.zero?
        if total_vote_count.zero?
          33
        else
          0
        end
      else
        (vote_count.to_f / total_vote_count * 100).round.abs
      end
    end
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      has_many :votes do
        link(:self) do
          {
            href: "#{object.class.try(:context_id_factory)&.call(object)}/votes",
            meta: {
              '@type': 'argu:votes'
            }
          }
        end
        meta do
          href = object.class.try(:context_id_factory)&.call(object)
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/votes"
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Commentable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :comments,
                      association: :filtered_threads,
                      pagination: true,
                      includes: {
                        default_vote_event: {},
                        parent: {},
                        creator: :profileable
                      }

      def filtered_threads(show_trashed = nil, page = nil, order = 'edges.created_at ASC')
        i = root_comments.order(order).page(page)
        unless show_trashed
          i.each do |edge|
            edge.shallow_wipe if edge.owner_type == 'Comment'
          end
        end
        i
      end
    end
  end
end

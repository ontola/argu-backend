# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    acts_as_commentable
    has_one :top_comment,
            -> { untrashed.where(parent_id: nil).order('comments.created_at ASC') },
            class_name: 'Comment',
            as: :commentable,
            dependent: :destroy

    with_collection :comments,
                    association: :filtered_threads,
                    pagination: true,
                    includes: [
                      :default_vote_event,
                      parent: :owner,
                      owner: {creator: :profileable}
                    ]

    def comment_edges(order = 'edges.created_at DESC')
      @comment_edges ||=
        Edge
          .joins("LEFT JOIN comments ON edges.owner_id = comments.id AND edges.owner_type = 'Comment'")
          .where(parent_id: edge.id, owner_type: 'Comment', comments: {parent_id: nil})
          .includes(owner: {creator: Profile.includes_for_profileable})
          .order(order)
    end

    def filtered_threads(show_trashed = nil, page = nil, order = 'edges.created_at ASC')
      i = comment_edges(order).page(page)
      unless show_trashed
        i.each do |edge|
          edge.owner.shallow_wipe if edge.owner_type == 'Comment'
        end
      end
      i
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :comments, predicate: NS::SCHEMA[:comments]

      def comment_collection
        object.comment_collection(user_context: scope)
      end
    end
  end
end

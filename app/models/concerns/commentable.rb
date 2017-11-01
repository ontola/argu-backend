# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    acts_as_commentable
    has_one :top_comment, -> { untrashed.order('comments.created_at ASC') }, class_name: 'Comment', as: :commentable

    with_collection :comments, association: :filtered_threads, pagination: true

    def mixed_comments(order = 'comments.created_at DESC')
      @mixed_comments ||=
        Edge
          .joins("LEFT JOIN comments ON edges.owner_id = comments.id AND edges.owner_type = 'Comment'")
          .where(parent_id: edge.id, owner_type: 'Comment', comments: {parent_id: nil})
          .includes(:parent, owner: {creator: Profile.includes_for_profileable})
          .order(order)
    end

    def filtered_threads(show_trashed = nil, page = nil, order = 'comments.created_at ASC')
      i = mixed_comments(order).page(page)
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
      has_one :comment_collection, predicate: RDF::SCHEMA[:comments]

      def comment_collection
        object.comment_collection(user_context: scope)
      end
    end
  end
end

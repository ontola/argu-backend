# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_one_through_edge :top_comment
    has_many_through_edge :comments

    with_collection :comments,
                    association: :filtered_threads,
                    pagination: true,
                    includes: [
                      :default_vote_event,
                      parent: :owner,
                      owner: {creator: :profileable}
                    ]

    def filtered_threads(show_trashed = nil, page = nil, order = 'edges.created_at ASC')
      i = edge.comments.order(order).page(page)
      unless show_trashed
        i.each do |edge|
          edge.owner.shallow_wipe if edge.owner_type == 'Comment'
        end
      end
      i
    end
  end

  module Actions
    extend ActiveSupport::Concern

    included do
      include ActionableHelper

      define_default_create_action :comment, image: 'fa-comment'
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :comments, predicate: NS::SCHEMA[:comments]
    end
  end
end

# frozen_string_literal: true

module Commentable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :comments,
                      association: :threads

      def filtered_threads(show_trashed = nil, page = nil)
        i = threads.page(page)
        unless show_trashed
          i.each do |edge|
            edge.shallow_wipe if edge.owner_type == 'Comment'
          end
        end
        i
      end
    end

    module ClassMethods
      def preview_includes
        super + [top_comment: :creator]
      end

      def show_includes
        super + [comment_collection: inc_shallow_collection]
      end
    end
  end
end

# frozen_string_literal: true
module Commentable
  extend ActiveSupport::Concern

  included do
    acts_as_commentable

    has_collection :comments, association: :filtered_threads, pagination: true

    def filtered_threads(show_trashed = nil, page = nil, order = 'created_at ASC')
      i = comment_threads.where(parent_id: nil).order(order).page(page)
      i.each(&shallow_wipe) unless show_trashed
      i
    end

    def shallow_wipe
      proc do |c|
        if c.is_trashed?
          c.body = '[DELETED]'
          c.creator = nil
          c.is_processed = true
        end
        c.children.each(&shallow_wipe) if c.children.present?
      end
    end

    def top_comment(_show_trashed = nil)
      @top_comment ||= comment_threads
                         .joins(:edge)
                         .untrashed
                         .order('created_at ASC').first
    end
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      has_one :comment_collection do
        link(:self) do
          {
            href: "#{object.context_id}/c",
            meta: {
              '@type': 'schema:comments'
            }
          }
        end
        meta do
          href = object.context_id
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/c"
          }
        end
      end

      def comment_collection
        object.comment_collection(user_context: scope)
      end
    end
  end
end

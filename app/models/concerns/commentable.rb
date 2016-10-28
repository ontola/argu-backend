# frozen_string_literal: true
module Commentable
  extend ActiveSupport::Concern

  included do
    acts_as_commentable

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
      @top_comment ||= comment_threads.where(parent_id: nil, is_trashed: false).order('created_at ASC').first
    end
  end
end

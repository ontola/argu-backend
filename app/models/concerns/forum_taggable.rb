# frozen_string_literal: true
module ForumTaggable
  extend ActiveSupport::Concern

  included do
    acts_as_ordered_taggable_on :tags
    accepts_nested_attributes_for :taggings

    after_save :mark_taggings_forum_id
  end

  def mark_taggings_forum_id
    ActiveRecord::Base.transaction do
      taggings.each do |t|
        t.forum_id = forum_id
        t.save
      end
    end
  end

  module ClassMethods
  end
end

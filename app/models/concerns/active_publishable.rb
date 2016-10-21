# frozen_string_literal: true
module ActivePublishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where("#{model_name.collection}.is_published = true") }
    scope :unpublished, -> { where('is_published = false') }

    has_many :publications,
             as: :publishable,
             inverse_of: :publishable,
             dependent: :destroy

    has_one :argu_publication,
            -> { where(channel: 'argu') },
            class_name: 'Publication',
            inverse_of: :publishable,
            as: :publishable

    accepts_nested_attributes_for :argu_publication
  end

  def is_draft?
    publications.empty?
  end

  def is_published?
    persisted? && is_published
  end

  def published_at
    argu_publication.try(:published_at)
  end

  module ClassMethods
    def published_for_user(user)
      where("#{class_name.tableize}.is_published = true OR #{class_name.tableize}.publisher_id = ? "\
            "OR #{class_name.tableize}.forum_id IN (?)",
            user&.id,
            user&.profile&.forum_ids(:manager) || [])
    end
  end
end

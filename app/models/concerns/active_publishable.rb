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
    publications.where('published_at IS NOT NULL').empty?
  end

  def is_published?
    persisted? && is_published
  end

  def published_at
    argu_publication.try(:published_at)
  end

  module ClassMethods
    def published_for_user(user)
      if user.present?
        owner_ids = user.managed_pages.joins(:profile).pluck(:'profiles.id').append(user.profile.id)
        forum_ids = user.profile.forum_ids(:manager)
      end
      where("(#{class_name.tableize}.is_published = true OR #{class_name.tableize}.creator_id IN (?) "\
            "OR #{class_name.tableize}.forum_id IN (?))",
            owner_ids || [],
            forum_ids || [])
    end
  end
end

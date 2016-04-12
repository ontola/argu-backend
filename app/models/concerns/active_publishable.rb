module ActivePublishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> do
      where('is_published = true')
    end
    scope :unpublished, -> do
      where('is_published = false')
    end

    attr_accessor :unpublish
    has_many :publications,
             as: :publishable,
             inverse_of: :publishable,
             dependent: :destroy
    has_one :argu_publication, -> {where(channel: 'argu')}, class_name: 'Publication', as: :publishable
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
  end
end

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

    attr_accessor :publish_at, :publish_type
    alias_attribute :published_at, :publish_at
    enum publish_type: {direct: 0, draft: 1, schedule: 2}
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

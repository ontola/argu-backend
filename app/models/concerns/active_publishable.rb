module ActivePublishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where('published_at <= ?', DateTime.current) }
    scope :unpublished, -> { where('published_at IS NULL OR published_at > ?', DateTime.current) }

    attr_accessor :unpublish
  end

  def is_draft?
    self[:published_at].blank?
  end

  def is_published?
    self[:published_at].present?
  end

  module ClassMethods
  end
end

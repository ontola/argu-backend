module ActivePublishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where.not(published: nil) }

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

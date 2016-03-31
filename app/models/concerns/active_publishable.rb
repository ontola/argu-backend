module ActivePublishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> do
      scope = where('published_at <= ?', DateTime.current)
      if self.respond_to?(:ends_at)
        scope = scope.where('ends_at IS NULL OR ends_at > ?',
                            DateTime.current)
      end
      scope
    end
    scope :unpublished, -> do
      where('published_at IS NULL OR published_at > ?',
            DateTime.current)
    end
    scope :ended, -> do
      scope = where('published_at IS NOT NULL')
      if self.respond_to?(:ends_at)
        scope = scope.where('ends_at IS NOT NULL AND ends_at < ?',
                            DateTime.current)
      end
      scope
    end

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

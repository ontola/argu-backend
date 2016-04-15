module ActivePublishable
  extend ActiveSupport::Concern

  included do
    def self.published
      scope = where('published_at <= ?', DateTime.current)
      if column_names.include?('ends_at')
        scope = scope.where('ends_at IS NULL OR ends_at > ?',
                            DateTime.current)
      end
      scope
    end

    def self.unpublished
      where('published_at IS NULL OR published_at > ?',
            DateTime.current)
    end

    def self.ended
      scope = where('published_at IS NOT NULL')
      if column_names.include?('ends_at')
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

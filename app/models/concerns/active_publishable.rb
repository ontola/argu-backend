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

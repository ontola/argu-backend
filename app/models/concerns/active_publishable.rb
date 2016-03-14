module ActivePublishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> do
      where('published_at <= ?', DateTime.current)
        .where('ends_at IS NULL OR ends_at > ?',
               DateTime.current)
    end
    scope :unpublished, -> do
      where('published_at IS NULL OR published_at > ?',
            DateTime.current)
    end
    scope :ended, -> do
      where('published_at IS NOT NULL')
      .where('ends_at IS NOT NULL AND ends_at < ?',
             DateTime.current)
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

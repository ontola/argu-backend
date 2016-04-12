class NewsBoy < ActiveRecord::Base
  self.abstract_class = true

  def self.published
    where('published_at <= ? AND (ends_at IS NULL OR ends_at > ?)',
          DateTime.current,
          DateTime.current)
  end

  def self.unpublished
    where('published_at IS NULL OR published_at > ? OR ends_at < ?',
          DateTime.current, DateTime.current)
  end

  def self.ended
    where('published_at IS NOT NULL AND ends_at IS NOT NULL AND ends_at < ?',
          DateTime.current)
  end

  def is_draft?
    self[:published_at].blank?
  end

  def is_published?
    self[:published_at].present? &&
        self[:published_at] < DateTime.current &&
        (self[:ends_at].nil? || self[:ends_at] > DateTime.current)
  end
end

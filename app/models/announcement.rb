class Announcement < ActiveRecord::Base
  include ArguBase

  belongs_to :publisher, class_name: 'Profile'

  enum audience: { guests: 0, users: 1, everyone: 3 }

  scope :published, -> { where('publish_at <= ?', DateTime.now) }
  scope :unpublished, -> { where('publish_at IS NULL OR publish_at > ?', DateTime.now) }

  validates :sample_size, length: { minimum: 1, maximum: 100 }
end

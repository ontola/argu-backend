class Banner < ActiveRecord::Base
  include ArguBase
  belongs_to :forum
  belongs_to :publisher, class_name: 'User'

  enum audience: { guests: 0, users: 1, members: 2, everyone: 3 }

  mount_uploader :cited_avatar, AvatarUploader

  scope :announcements, -> { where('forum_id IS NULL') }
  scope :published, -> { where('publish_at <= ?', DateTime.now) }
  scope :unpublished, -> { where('publish_at IS NULL OR publish_at > ?', DateTime.now) }

  validates :forum, :audience, presence: true
  #validates :sample_size, min: 1, max: 100, default: 100

end

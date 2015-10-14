class Banner < ActiveRecord::Base
  belongs_to :forum
  belongs_to :publisher, class_name: 'Profile'

  enum audience: { guests: 0, users: 1, members: 2, everyone: 3 }

  mount_uploader :cited_avatar, AvatarUploader

  scope :announcements, -> { where('forum_id IS NULL') }
  scope :published, -> { where('publish_at <= ?', DateTime.now) }
  scope :unpublished, -> { where('publish_at IS NULL OR publish_at > ?', DateTime.now) }

end
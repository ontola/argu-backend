class Announcement < ActiveRecord::Base
  include ArguBase, ActivePublishable

  belongs_to :publisher, class_name: 'Profile'

  enum audience: { guests: 0, users: 1, everyone: 3 }

  validates :sample_size, length: { minimum: 1, maximum: 100 }
end

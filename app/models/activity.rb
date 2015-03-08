class Activity < PublicActivity::Activity

  has_many :notifications, dependent: :destroy

  scope :since, ->(from_time = nil) { where('created_at < :from_time', {from_time: from_time}) if from_time.present? }
end

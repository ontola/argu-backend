class Activity < PublicActivity::Activity
  has_many :notifications, dependent: :destroy
  belongs_to :owner, class_name: 'Profile'
  belongs_to :forum

  validates_presence_of :forum, :key, :trackable, :owner, :recipient

  scope :since, ->(from_time = nil) { where('created_at < :from_time', {from_time: from_time}) if from_time.present? }

  def action
    key.split('.').last
  end

  def object
    trackable_type.downcase
  end
end

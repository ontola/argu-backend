class Activity < PublicActivity::Activity

  has_many :notifications, dependent: :destroy
  belongs_to :owner, class_name: 'Profile'

  scope :since, ->(from_time = nil) { where('created_at < :from_time', {from_time: from_time}) if from_time.present? }

  def action
    key.split('.').last
  end

  def object
    trackable_type.downcase
  end

  def followers
    mailer = "#{object}_follower_collector".classify.safe_constantize
    if mailer
      mailer.new(self).send(action)
    else
      []
    end
  end
end

class Notification < ActiveRecord::Base
  include ActivityStringHelper
  belongs_to :profile
  belongs_to :activity
  after_destroy :sync_notification_count
  after_update :sync_notification_count

  validates :title, length: {maximum: 75}
  validates :url, length: {maximum: 255}

  def sync_notification_count
    self.profile.profileable.sync_notification_count
  end

  def title
    if self.activity.present?
      activity_string_for(self.activity)
    else
      super
    end
  end

  def url_object
    if self.activity.present?
      self.activity.trackable
    else
      self.url
    end
  end

  def image
    if self.activity.present?
      self.activity.owner.profile_photo.url(:avatar)
    else
      ActionController::Base.helpers.asset_path('favicons/favicon-192x192.png')
    end
  end

  scope :since, ->(from_time = nil) { where('created_at < :from_time', {from_time: from_time}) if from_time.present? }

end

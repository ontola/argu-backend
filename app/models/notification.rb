class Notification < ActiveRecord::Base
  include ActivityStringHelper
  belongs_to :profile
  belongs_to :activity


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
      ''
    end
  end

  def image
    if self.activity.present?
      self.activity.owner.profile_photo.url(:avatar)
    else
      ActionController::Base.helpers.asset_path('favicons/favicon-192x192.png')
    end
  end

end

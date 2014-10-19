class Profile < ActiveRecord::Base
  belongs_to :user

  mount_uploader :profile_photo, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  ######Attributes#######
  def display_name
    self.name.presence || self.user.username
  end

  #######Utility#########
  def self.find_by_username(user)
    return (User.find_by_username(user)).try(:profile)
  end
end
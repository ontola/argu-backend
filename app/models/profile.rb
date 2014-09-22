class Profile < ActiveRecord::Base
  belongs_to :user

  has_attached_file :profile_photo
  validates_attachment_content_type :profile_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]
  has_attached_file :cover_photo
  validates_attachment_content_type :cover_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]

  ######Attributes#######
  def display_name
    self.name.presence || self.user.username
  end

  #######Utility#########
  def self.find(id)
    @profile = Profile.find_by_username(id)
    @profile ||= Profile.find_by_id(id)
    @profile ||= super(id)
  end

  def self.find_by_username(user)
    return (User.find_by_username(user)).try(:profile)
  end
end
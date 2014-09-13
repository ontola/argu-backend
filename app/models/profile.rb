class Profile < ActiveRecord::Base
  belongs_to :user

  has_attached_file :profile_photo
  has_attached_file :cover_photo

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
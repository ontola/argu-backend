class Organisation < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships

  has_attached_file :profile_photo
  validates_attachment_content_type :profile_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]
  has_attached_file :cover_photo
  validates_attachment_content_type :cover_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]

  resourcify

  ######Attributes#######
  def key_tags
    super.split(',').map &:strip
  end

  def key_tags_raw
    self.attribute :key_tags
  end

  ######Roles#######
  def managers
    User.with_role :manager, self
  end
end

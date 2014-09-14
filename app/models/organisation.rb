class Organisation < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  accepts_nested_attributes_for :memberships, :reject_if => :all_blank, :allow_destroy => true
  has_many :statements

  has_attached_file :profile_photo
  validates_attachment_content_type :profile_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]
  has_attached_file :cover_photo, styles: { :cropped => '1500' }
  validates_attachment_content_type :cover_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]
  crop_attached_file :cover_photo, :aspect => "15:4"

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

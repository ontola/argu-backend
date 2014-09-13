class Organisation < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships

  has_attached_file :profile_photo
  has_attached_file :cover_photo

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

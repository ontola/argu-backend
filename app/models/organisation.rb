class Organisation < ActiveRecord::Base
  has_many :users

  has_attached_file :profile_photo
  has_attached_file :cover_photo

  def key_tags
    super.split(',').map &:strip
  end

  def key_tags_raw
    self.attribute :key_tags
  end
end

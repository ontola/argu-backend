class ForumSerializer < BaseSerializer
  attributes :shortname, :profile_photo
  attribute :name, key: :title
  
  def shortname
    object.shortname.shortname
  end
  
  def profile_photo
    object.default_profile_photo.url
  end
end

class UserSerializer < BaseSerializer
  attributes :display_name, :profile_photo

  def profile_photo
    object.profile.default_profile_photo
  end
end

class ProfileSerializer < BaseSerializer
  attributes :display_name, :profile_photo_url, :user_url

  def profile_photo_url
    object.profile_photo.url
  end

  def user_url
    Rails.application.routes.url_helpers.url_for(controller: 'users',
                                                 action: 'show',
                                                 id: object.profileable.display_name,
                                                 only_path: true)
  end
end

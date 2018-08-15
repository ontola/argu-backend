# frozen_string_literal: true

json.profiles @profiles.limit(30) do |profile|
  json.id profile.id
  json.url dual_profile_url(profile)
  json.shortname profile.url
  json.name profile.display_name
  json.email profile.profileable.email if current_user.is_staff?
  json.profile_photo do
    json.url profile.default_profile_photo.url
    json.icon do
      json.url profile.default_profile_photo.icon&.url
    end
    json.avatar do
      json.url profile.default_profile_photo.avatar&.url
    end
  end
end

json.profiles @profiles do |profile|
  json.id profile.id
  json.url dual_profile_path(profile)
  json.shortname profile.url
  json.name profile.name
  json.profile_photo do
    json.url profile.profile_photo.url
    json.icon do
      json.url profile.profile_photo.icon.url
    end
    json.avatar do
      json.url profile.profile_photo.avatar.url
    end
  end
end
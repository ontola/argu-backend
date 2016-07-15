# frozen_string_literal: true
json.users @users do |user|
  json.id user.id
  json.shortname user.url
  json.profile do
    json.name user.profile.name
    json.profile_photo user.profile.default_profile_photo.url
  end
end

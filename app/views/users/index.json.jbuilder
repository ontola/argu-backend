json.users @users do |user|
  json.id user.id
  json.username user.username
  json.profile do
    json.name user.profile.name
    json.profile_photo user.profile.profile_photo
  end
end
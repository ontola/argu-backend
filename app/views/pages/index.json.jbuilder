json.pages @pages do |page|
  json.id page.id
  json.web_url page.web_url
  json.profile do
    json.name page.profile.name
    json.profile_photo do
      json.url page.profile.profile_photo.url
      json.icon do
        json.url page.profile.profile_photo.icon.url
      end
      json.avatar do
        json.url page.profile.profile_photo.avatar.url
      end
    end
  end
end
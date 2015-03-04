json.user do
  json.username @profile.username
  json.name @profile.name
  json.url @profile.owner.class == User ? profile_path(@profile.username) : page_path(@profile.owner.web_url)
  json.profile_photo do
    json.url @profile.profile_photo.url
    json.icon do
      json.url @profile.profile_photo.url(:icon)
    end
    json.avatar do
      json.url @profile.profile_photo.url(:avatar)
    end
  end
  json.memberships @profile.memberships do |membership|
    json.url forum_path membership.forum.web_url
    json.forum membership.forum.web_url
    json.title membership.forum.display_name
  end
end
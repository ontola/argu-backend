json.user do
  json.shortname @profile.url
  json.name @profile.name
  json.url @profile.owner.class == User ? profile_path(@profile.url) : page_path(@profile.owner.url)
  json.profile_photo do
    json.url @profile.default_profile_photo.url
    json.icon do
      json.url @profile.default_profile_photo.url(:icon)
    end
    json.avatar do
      json.url @profile.default_profile_photo.url(:avatar)
    end
  end
  json.memberships @profile.memberships do |membership|
    json.url forum_path membership.forum.url
    json.forum membership.forum.url
    json.title membership.forum.display_name
  end
end

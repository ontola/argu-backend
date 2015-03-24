json.current_actor do
  json.shortname @profile.url
  json.display_name @profile.display_name
  json.name @profile.name
  json.url dual_profile_path(@profile)
  json.current_forum do
    json.display_name @profile.preferred_forum.display_name
    json.shortname @profile.preferred_forum.url
    json.cover_photo @profile.preferred_forum.cover_photo
  end
  json.profile_photo do
    json.url @profile.profile_photo.url
    json.icon do
      json.url @profile.profile_photo.url(:icon)
    end
    json.avatar do
      json.url @profile.profile_photo.url(:avatar)
    end
  end
  json.groups @profile.groups do |group|
    json.id group.id
    json.name group.name
  end
  json.managed_pages current_user.managed_pages do |page|
    json.title page.display_name
    json.url page_path(page)
    json.update_url actors_path(na: page.profile.id)
    json.profile_photo do
      json.url page.profile.profile_photo.url
      json.icon do
        json.url page.profile.profile_photo.url(:icon)
      end
    end
  end
end
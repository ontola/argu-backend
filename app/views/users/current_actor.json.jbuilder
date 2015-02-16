json.current_actor do
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
  json.managed_pages @profile.owner.managed_pages do |page|
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
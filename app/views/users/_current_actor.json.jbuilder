json.current_actor do
  json.userState user_state
  if @profile.present?
    json.finishedIntro current_user.finished_intro
    json.activeId @profile.id
    json.actor_type @profile.profileable.class.name

    json.current_forum do
      json.display_name current_user.profile.preferred_forum.display_name
      json.shortname current_user.profile.preferred_forum.url
      json.cover_photo current_user.profile.preferred_forum.default_cover_photo
    end
    json.profile_photo do
      json.url @profile.default_profile_photo.url
      json.icon do
        json.url @profile.default_profile_photo.url(:icon)
      end
      json.avatar do
        json.url @profile.default_profile_photo.url(:avatar)
      end
    end
    json.groups policy_scope(@profile.groups) do |group|
      json.id group.id
      json.name group.name
    end
    json.managed_pages managed_pages_items(current_user) do |page|
      json.title page.display_name
      json.url page.url
      json.id page.id
      json.update_url page.update_url
      json.image do
        json.url page.default_profile_photo.url
        json.icon do
          json.url page.default_profile_photo.url(:icon)
        end
      end
    end
  end
end

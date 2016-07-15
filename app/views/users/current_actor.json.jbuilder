# frozen_string_literal: true
json.current_actor do
  json.actor_type @profile.owner.class.name
  json.shortname @profile.url
  json.display_name @profile.display_name
  json.name @profile.name
  json.url dual_profile_url(@profile)
  json.current_forum do
    json.display_name @profile.preferred_forum.display_name
    json.shortname @profile.preferred_forum.url
    json.cover_photo @profile.preferred_forum.default_cover_photo
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
  json.managed_pages current_user.managed_pages do |page|
    json.title page.display_name
    json.url page_path(page)
    json.update_url actors_path(na: page.profile.id)
    json.profile_photo do
      json.url page.profile.default_profile_photo.url
      json.icon do
        json.url page.profile.default_profile_photo.url(:icon)
      end
    end
  end
end

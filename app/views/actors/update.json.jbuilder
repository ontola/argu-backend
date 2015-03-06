json.display_name @new_actor.display_name
json.image do
  json.url @new_actor.profile_photo.url(:icon)
end
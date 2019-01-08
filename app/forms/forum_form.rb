# frozen_string_literal: true

class ForumForm < RailsLD::Form
  fields %i[
    display_name
    bio
    bio_long
    url
    language
    default_profile_photo
    default_cover_photo
    public_grant
  ]
end

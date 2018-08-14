# frozen_string_literal: true

class ForumForm < FormsBase
  fields %i[
    display_name
    bio
    bio_long
    url
    language
    default_profile_photo
    default_cover_photo
  ]
end

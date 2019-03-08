# frozen_string_literal: true

class BlogForm < RailsLD::Form
  fields %i[
    display_name
    url
    language
    default_profile_photo
    default_cover_photo
    public_grant
  ]
end

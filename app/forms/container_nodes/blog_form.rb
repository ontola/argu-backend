# frozen_string_literal: true

class BlogForm < RailsLD::Form
  fields %i[
    display_name
    bio
    bio_long
    locale
    url
    language
    default_cover_photo
    public_grant
  ]
end

# frozen_string_literal: true

class ForumForm < ApplicationForm
  fields %i[
    display_name
    bio
    bio_long
    url
    language
    default_cover_photo
    public_grant
  ]
end

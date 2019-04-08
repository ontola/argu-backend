# frozen_string_literal: true

class DataCatalogForm < RailsLD::Form
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

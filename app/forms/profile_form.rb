# frozen_string_literal: true

class ProfileForm < ApplicationForm
  fields [
    :name,
    :about,
    {default_profile_photo: {min_count: 0}},
    :default_cover_photo
  ]
end

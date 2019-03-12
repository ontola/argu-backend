# frozen_string_literal: true

class ProfileForm < ApplicationForm
  fields %i[
    name
    about
    default_profile_photo
    default_cover_photo
  ]
end

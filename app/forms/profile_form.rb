# frozen_string_literal: true

class ProfileForm < FormsBase
  fields %i[
    name
    about
    default_profile_photo
    default_cover_photo
  ]
end

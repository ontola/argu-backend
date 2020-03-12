# frozen_string_literal: true

module Users
  class ProfileForm < ApplicationForm
    fields [
      :first_name,
      :last_name,
      :hide_last_name,
      :about,
      {default_profile_photo: {min_count: 0}},
      :default_cover_photo
    ]
  end
end

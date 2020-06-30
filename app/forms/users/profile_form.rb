# frozen_string_literal: true

module Users
  class ProfileForm < ApplicationForm
    field :first_name
    field :last_name
    field :hide_last_name
    field :about
    has_one :default_profile_photo
    has_one :default_cover_photo
  end
end

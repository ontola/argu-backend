# frozen_string_literal: true

require 'argu/not_authorized_error'

module ActorsHelper
  def managed_profiles_list
    @managed_profiles_list ||=
      current_user.managed_profiles.includes(:default_profile_photo, :profileable).map do |profile|
        managed_profiles_list_item(profile)
      end
  end

  def managed_profiles_list_item(profile)
    {
      label: profile.display_name,
      image: profile.default_profile_photo.url(:icon),
      value: profile.profileable.context_id
    }
  end
end

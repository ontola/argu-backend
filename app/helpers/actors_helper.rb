# frozen_string_literal: true

require 'argu/errors/not_authorized'

module ActorsHelper
  def managed_profiles_list
    @managed_profiles_list ||=
      [managed_profiles_list_item(current_user.profile)].concat(
        current_user.managed_pages.includes(:edge, profile: :default_profile_photo).map do |page|
          managed_profiles_list_item(page.profile)
        end
      )
  end

  def managed_profiles_list_item(profile)
    {
      label: profile.display_name,
      image: profile.default_profile_photo.url(:icon),
      value: profile.profileable.iri
    }
  end
end

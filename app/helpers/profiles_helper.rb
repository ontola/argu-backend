# frozen_string_literal: true

module ProfilesHelper
  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_url(profile, only_path: true, canonical: false)
    profile = Profile.community if profile.profileable.blank?
    if canonical
      profile.canonical_iri(only_path: only_path).to_s
    else
      profile.iri(only_path: only_path).to_s
    end
  end
end

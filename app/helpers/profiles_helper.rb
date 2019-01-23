# frozen_string_literal: true

module ProfilesHelper
  include UriTemplateHelper

  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_url(profile, only_path: true, canonical: false)
    profile = Profile.community if profile.profileable.blank?
    iri = canonical ? profile.profileable.canonical_iri : profile.profileable.iri
    only_path ? iri.path : iri
  end
end

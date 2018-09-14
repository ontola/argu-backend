# frozen_string_literal: true

module ProfilesHelper
  include UriTemplateHelper

  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_url(profile, only_path: true, canonical: false)
    profile = Profile.community if profile.profileable.blank?
    path = canonical ? URI(profile.profileable.canonical_iri_path) : URI(profile.profileable.iri_path)
    path.query = "page_id=#{tree_root.url}" if respond_to?(:tree_root_id) && tree_root_id.present?
    only_path ? path.to_s : RDF::DynamicURI.intern(path_with_hostname(path))
  end
end

# frozen_string_literal: true

module ProfilesHelper
  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_url(profile, only_path: true, canonical: false)
    profile = Profile.community if profile.profileable.blank?
    url =
      if canonical
        profile.canonical_iri(only_path: only_path)
      else
        profile.iri(only_path: only_path)
      end
    respond_to?(:tree_root_id) && tree_root_id.present? ? "#{url}?page_id=#{tree_root.url}" : url.to_s
  end
end

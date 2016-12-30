# frozen_string_literal: true
module ProfilesHelper
  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_url(profile, only_path: true, canonical: false)
    if profile.profileable.class == User
      if canonical
        user_url(profile.profileable.id, only_path: only_path)
      else
        user_url(profile.profileable, only_path: only_path)
      end
    elsif profile.profileable.class == Page
      page_url(profile.profileable, only_path: only_path)
    else
      'deleted'
    end
  end

  # Generates a link to the Profile's profileable edit action
  # Either a Page or a User
  def dual_profile_edit_url(profile)
    if profile.profileable.class == User
      edit_user_url(profile.profileable)
    elsif profile.profileable.class == Page
      settings_page_url(profile.profileable)
    else
      'deleted'
    end
  end
end

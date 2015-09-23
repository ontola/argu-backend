module ProfilesHelper
  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_url(profile)
    if profile.profileable.class == User
      user_url(profile.profileable)
    elsif profile.profileable.class == Page
      page_url(profile.profileable)
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

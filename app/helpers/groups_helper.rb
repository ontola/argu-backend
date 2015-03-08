module GroupsHelper

  def profile_in_group?(profile, group)
    if profile.owner.class == Page
      profile.owner.groups.include?(group)
    end
  end

end

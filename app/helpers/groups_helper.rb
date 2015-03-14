module GroupsHelper

  def profile_in_group?(profile, group)
    profile && profile.groups.include?(group)
  end

end

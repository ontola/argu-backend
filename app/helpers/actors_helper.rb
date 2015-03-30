module ActorsHelper

  # Finds a Profile based on the `a_a` cookie value.
  # @return [Profile] the profile which the current_user is using to do actions with.
  def get_current_actor
    if cookies[:a_a]
      p = Profile.find(cookies[:a_a])
      raise 'not authorized' unless ActorPolicy.new(UserContext.new(current_user, nil, session), p).show?
      return p
    else
      current_user.profile
    end
  end
end

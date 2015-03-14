module ActorsHelper
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

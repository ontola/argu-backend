# frozen_string_literal: true
module ActorsHelper
  # Finds a Profile based on the `a_a` cookie value.
  # @return [Profile] the profile which the current_user is using to do actions with.
  def get_current_actor
    @_current_actor ||=
      if actor_token
        p = Profile.find(actor_token)
        raise 'not authorized' unless ActorPolicy.new(UserContext.new(current_user, nil, session[:a_tokens]), p).show?
        p
      else
        current_user.profile
      end
  end

  def reset_current_actor
    cookies.delete :a_a
  end

  private

  def actor_token
    cookies[:a_a] || request.headers['X-Argu-Actor']
  end
end

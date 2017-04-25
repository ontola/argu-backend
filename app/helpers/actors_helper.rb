# frozen_string_literal: true
require 'argu/not_authorized_error'

module ActorsHelper
  # Finds a Profile based on the `a_a` cookie value.
  # @return [Profile] the profile which the current_user is using to do actions with.
  def get_current_actor
    @_current_actor ||=
      if actor_token
        ca = CurrentActor.new(user: current_user, actor: Profile.find(actor_token))
        policy = CurrentActorPolicy.new(UserContext.new(current_user, nil, doorkeeper_scopes), ca)
        unless policy.show?
          raise Argu::NotAuthorizedError.new(
            query: 'show?',
            record: ca,
            policy: policy,
            verdict: policy.last_verdict
          )
        end
        ca.actor
      else
        current_user.profile
      end
  end

  def reset_current_actor
    cookies.delete :a_a
  end

  private

  def actor_token
    reset_current_actor if current_user.guest?
    cookies[:a_a] || request.headers['X-Argu-Actor']
  end
end

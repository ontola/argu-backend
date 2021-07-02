# frozen_string_literal: true

class ActorsController < ParentableController
  private

  def verify_authorized?
    false
  end

  def available_actors
    return [] if current_user.guest?
    return [current_user, ActsAsTenant.current_tenant] if user_context.page_manager?

    [current_user]
  end

  def current_resource
    current_actor
  end

  def requested_resource
    return super unless action_name == 'index'

    skip_verify_policy_scoped(true)

    @requested_resource ||= LinkedRails::Sequence.new(
      available_actors,
      id: index_iri,
      member_includes: CurrentActor.preview_includes,
      scope: false
    )
  end
end

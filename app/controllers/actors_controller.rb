# frozen_string_literal: true

class ActorsController < ParentableController
  private

  def verify_authorized?
    false
  end

  def available_actors
    return [] if current_user.guest?

    [current_user] + current_user.managed_pages.includes(:default_cover_photo, :shortname, :default_profile_photo)
  end

  def current_resource
    current_actor
  end

  def index_association
    skip_verify_policy_scoped(true)

    @index_association ||= available_actors
  end

  def preview_includes
    %i[default_profile_photo]
  end

  def show_includes
    %i[default_profile_photo user actor]
  end
end

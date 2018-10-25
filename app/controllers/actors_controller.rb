# frozen_string_literal: true

class ActorsController < ParentableController
  skip_before_action :authorize_action

  private

  def current_resource
    current_actor
  end

  def index_collection
    [current_user] +
      current_user.managed_pages.includes(:default_cover_photo, :shortname, profile: :default_profile_photo)
  end

  def index_includes_collection
    [:default_profile_photo]
  end

  def show_includes
    %i[default_profile_photo user actor]
  end
end

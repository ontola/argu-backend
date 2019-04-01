# frozen_string_literal: true

class ActorsController < ParentableController
  skip_before_action :authorize_action

  private

  def cache_per_user?
    true
  end

  def cache_key_timestamp
    @cache_key_timestamp ||= [current_user.updated_at, current_profile.updated_at].max
  end

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
end

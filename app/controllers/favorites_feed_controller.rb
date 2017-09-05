# frozen_string_literal: true

class FavoritesFeedController < FeedController
  private

  def authenticated_tree; end

  def authorize_action
    skip_verify_policy_authorized true
    raise Argu::NotAuthorizedError.new(query: :feed?) unless current_user.is_staff?
  end

  def feed
    Activity.feed_for_favorites(current_user.favorites, !current_user.is_staff?)
  end

  def resource_by_id; end

  def parent_resource; end
end

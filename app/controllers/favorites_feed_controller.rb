# frozen_string_literal: true
class FavoritesFeedController < FeedController
  private

  def authorize_action
    skip_verify_policy_authorized true
    raise NotAuthorizedError.new(query: :feed?) unless current_user.profile.has_role?(:staff)
  end

  def feed
    Activity.feed_for_favorites(current_user.favorites)
  end
end

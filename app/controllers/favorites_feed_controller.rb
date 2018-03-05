# frozen_string_literal: true

class FavoritesFeedController < FeedController
  private

  def authorize_action
    skip_verify_policy_authorized true
    raise Argu::Errors::NotAuthorized.new(query: :feed?) unless current_user.is_staff?
  end

  def controller_class
    Feed
  end

  def feed_resource
    current_user
  end

  def tree_root_id
    GrantTree::ANY_ROOT
  end

  def parent_resource; end
end

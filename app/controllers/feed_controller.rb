# frozen_string_literal: true

class FeedController < AuthorizedController
  private

  def authorize_action
    authorize parent_resource!.parent, :feed?
  end
end

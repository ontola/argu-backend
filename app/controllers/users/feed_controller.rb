# frozen_string_literal: true

module Users
  class FeedController < ::FeedController
    private

    def feed
      Activity.feed_for_profile(authenticated_resource.profile)
    end
  end
end

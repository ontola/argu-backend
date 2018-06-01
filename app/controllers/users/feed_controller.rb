# frozen_string_literal: true

module Users
  class FeedController < ::FeedController
    private

    def tree_root_id; end

    def feed_resource
      parent_resource.profile
    end
  end
end

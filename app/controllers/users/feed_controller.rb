# frozen_string_literal: true

module Users
  class FeedController < ::FeedController
    private

    def tree_root_id
      GrantTree::ANY_ROOT
    end

    def feed_resource
      parent_resource.profile
    end
  end
end

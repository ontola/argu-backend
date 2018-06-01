# frozen_string_literal: true

module Users
  class FeedController < ::FeedController
    private

    def tree_root_id
      @tree_root_id ||= Page.find_via_shortname_or_id!(params[:page_id]).root_id
    end

    def feed_resource
      parent_resource.profile
    end
  end
end

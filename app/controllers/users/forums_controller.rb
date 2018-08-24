# frozen_string_literal: true

module Users
  class ForumsController < EdgeableController
    skip_before_action :authorize_action, only: %i[index]

    def index_success_html
      edge_ids =
        current_user
          .profile
          .granted_edges(root_id: tree_root_id, grant_set: %w[moderator administrator])
          .pluck(:uuid)
          .uniq
      @forums = Forum.joins(:parent).where('edges.uuid IN (?) OR parents_edges.uuid IN (?)', edge_ids, edge_ids)
      @_pundit_policy_scoped = true
    end
  end
end

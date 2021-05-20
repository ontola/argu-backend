# frozen_string_literal: true

class GrantSetsController < AuthorizedController
  private

  def requested_resource
    @requested_resource ||=
      if (/[a-zA-Z]/i =~ params[:id]).nil?
        GrantSet.find_by(id: params[:id])
      else
        GrantSet.find_by(title: params[:id])
      end
  end

  def index_association
    skip_verify_policy_scoped(true)

    @index_association ||=
      user_context.grant_tree.grant_sets(parent_resource!.persisted_edge, group_ids: current_profile.group_ids)
  end
end

# frozen_string_literal: true

class GrantedGroupsController < AuthorizedController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_association
    skip_verify_policy_scoped(true)

    @index_association ||=
      user_context.grant_tree.granted_groups(parent_resource!.persisted_edge)
  end
end

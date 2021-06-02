# frozen_string_literal: true

class GrantedGroupsController < AuthorizedController
  private

  def authorize_action
    authorize parent_from_params, :show?
  end

  def requested_resource
    return unless action_name == 'index'

    skip_verify_policy_scoped(true)

    @requested_resource ||= LinkedRails::Sequence.new(
      user_context.grant_tree.granted_groups(parent_from_params.persisted_edge),
      id: index_iri,
      scope: false
    )
  end
end

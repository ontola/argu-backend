# frozen_string_literal: true

class GrantTreesController < AuthorizedController
  include NestedResourceHelper

  private

  def authorize_action
    authorize parent_resource!, :index_children?, :grants
  end

  def show_includes
    [permission_groups: :permissions]
  end

  def authenticated_resource
    user_context.grant_tree.cache_node(parent_resource)
  end
end

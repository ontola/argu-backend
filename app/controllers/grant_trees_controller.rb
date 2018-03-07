# frozen_string_literal: true

class GrantTreesController < AuthorizedController
  include NestedResourceHelper
  include Common::Show

  private

  def authorize_action
    authorize parent_resource!, :index_children?, :grants
  end

  def include_show
    [permission_groups: :permissions]
  end

  def authenticated_resource
    user_context.grant_tree.cache_node(parent_resource)
  end

  alias parent_edge parent_resource

  def tree_root_id
    @tree_root_id ||= parent_resource&.root_id
  end
end

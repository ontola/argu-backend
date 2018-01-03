# frozen_string_literal: true

class MenusController < ParentableController
  skip_before_action :check_if_registered
  before_action :authorize_action

  private

  def authenticated_tree
    parent_resource.try(:edge)&.self_and_ancestors
  end

  def authorize_action
    skip_verify_policy_scoped(true)
    if parent_resource.present?
      authorize parent_resource, :show?
    else
      skip_verify_policy_authorized(true)
    end
  end

  def current_forum; end

  def include_index
    [menu_sequence: [members: [menu_sequence: :members]]]
  end

  def include_show
    [menu_sequence: [members: [menu_sequence: [members: [menu_sequence: :members]]]]]
  end

  def index_response_association
    if parent_resource.present?
      parent_resource.menus(user_context)
    else
      ApplicationMenuList.new(resource: current_user, user_context: user_context).menus
    end
  end

  def resource_by_id
    if parent_resource.present?
      parent_resource.menu(user_context, params[:id].to_sym)
    else
      ApplicationMenuList.new(resource: current_user, user_context: user_context).menu[params[:id].to_sym]
    end
  end

  def resource_by_id_parent; end
end

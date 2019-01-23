# frozen_string_literal: true

class MenusController < ParentableController
  skip_before_action :check_if_registered
  before_action :authorize_action

  private

  def authorize_action
    skip_verify_policy_scoped(true)
    if parent_resource.present?
      authorize parent_resource, :show?
    else
      skip_verify_policy_authorized(true)
    end
  end

  def current_forum; end

  def index_includes
    [menu_sequence: [members: [menu_sequence: :members]]]
  end

  def show_includes
    [
      menu_sequence: [
        members: MenuItem.preview_includes + [
          menu_sequence: [members: [MenuItem.preview_includes, menu_sequence: [members: MenuItem.preview_includes]]]
        ]
      ]
    ]
  end

  def index_association
    if parent_resource.present?
      parent_resource.menus(user_context)
    else
      ApplicationMenuList.new(resource: current_user, user_context: user_context).menus
    end
  end

  def resource_by_id # rubocop:disable Metrics/AbcSize
    @_resource_by_id ||=
      if parent_resource.present?
        parent_resource.menu(user_context, params[:id].to_sym)
      else
        ApplicationMenuList.new(resource: current_user, user_context: user_context).menu[params[:id].to_sym]
      end
  end

  def resource_by_id_parent; end
end

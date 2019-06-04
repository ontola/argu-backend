# frozen_string_literal: true

class SubMenusController < ParentableController
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

  def index_association
    menu&.menu_sequence || raise(ActiveRecord::RecordNotFound)
  end

  def index_includes
    [
      members: MenuItem.preview_includes + [
        menu_sequence: [
          members: MenuItem.preview_includes +
            [menu_sequence: [members: MenuItem.preview_includes]]
        ]
      ]
    ]
  end

  def menu
    if parent_resource.present?
      parent_resource.menus(user_context).menu(menu_id)
    else
      AppMenuList.new(resource: current_user, user_context: user_context).menu(menu_id)
    end
  end

  def menu_id
    params[:menu_id].to_sym
  end

  def parent_resource
    @parent_resource ||=
      parent_from_params(tree_root, params.except(:menu_id)) || !request.path.start_with?('/apex/') && tree_root || nil
  end
end

# frozen_string_literal: true

class SubMenusController < ParentableController
  skip_before_action :check_if_registered
  before_action :authorize_action

  private

  def authorize_action
    skip_verify_policy_scoped(true)
    authorize parent_resource, :show?
  end

  def index_association
    menu = parent_resource.menu(user_context, params[:menu_id].to_sym) || raise(ActiveRecord::RecordNotFound)
    menu.menu_sequence
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

  def parent_resource
    parent_from_params(params.except(:menu_id))
  end
end

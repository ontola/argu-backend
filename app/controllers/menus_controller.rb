# frozen_string_literal: true

class MenusController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered
  before_action :authorize_action

  def show
    respond_to do |format|
      format.json_api do
        render json: resource_by_id!, include: include_show
      end
      format.nt do
        render nt: resource_by_id!, include: include_show
      end
    end
  end

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
    [menus: :menus]
  end

  def include_show
    [menus: [menus: :menus]]
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

  def parent_resource
    super if parent_id_from_params.present?
  end
end

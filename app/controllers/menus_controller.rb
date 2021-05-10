# frozen_string_literal: true

class MenusController < LinkedRails::MenusController
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

  def custom_menu
    return if menu_list.blank?

    @custom_menu ||= LinkedRails.menus_item_class.new(
      menus: menu_list.custom_menu_items(menu_tag, parent_resource),
      parent: menu_list,
      resource: parent_resource,
      tag: menu_tag
    )
  end

  def menu_tag
    @menu_tag ||= params[:id].to_sym
  end

  def requested_resource
    super || custom_menu if action_name == 'show'
  end
end

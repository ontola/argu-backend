# frozen_string_literal: true

class SubMenusController < LinkedRails::SubMenusController
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

  def parent_resource
    @parent_resource ||= super || !app_menu? && tree_root || nil
  end
end

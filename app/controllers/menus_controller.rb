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

  def resource_by_id
    requested_resource if action_name == 'show'
  end
end

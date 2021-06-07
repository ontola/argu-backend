# frozen_string_literal: true

class GrantsController < ServiceController
  private

  def ld_action_name(_view)
    ACTION_MAP[action_name.to_sym] || action_name.to_sym
  end

  def create_service_parent
    nil
  end

  def redirect_location
    settings_iri(authenticated_resource.root, tab: :groups)
  end
end

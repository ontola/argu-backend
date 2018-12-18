# frozen_string_literal: true

class InvitesController < ParentableController
  active_response :new

  private

  def resource_new_params
    {edge: parent_resource!}
  end
end

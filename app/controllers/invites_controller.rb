# frozen_string_literal: true

class InvitesController < ParentableController
  active_response :new

  private

  def resource_new_params
    {
      creator: current_user.iri,
      edge: parent_resource!,
      message: I18n.t('tokens.discussion.default_message', resource: parent_resource!.display_name),
      redirect_url: parent_resource!.iri.to_s,
      root_id: parent_resource!.root_id,
      send_mail: true
    }
  end
end

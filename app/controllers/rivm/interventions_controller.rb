# frozen_string_literal: true

class InterventionsController < EdgeableController
  private

  def active_response_success_message
    return super unless resource_was_published? && current_resource.argu_publication.publish_time_lapsed?

    I18n.t('interventions.publish_success')
  end

  def create_service_parent
    Edge.find(params.require(:intervention).require(:parent_id))
  end

  def permit_params
    super.except(:parent_id)
  end
end

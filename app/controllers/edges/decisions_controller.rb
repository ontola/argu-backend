# frozen_string_literal: true

class DecisionsController < EdgeableController
  private

  def active_response_success_message
    if authenticated_resource.argu_publication.published_at.present?
      parent_key = authenticated_resource.parent.model_name.singular
      I18n.t("decisions.#{parent_key}.#{authenticated_resource.state}")
    else
      I18n.t('type_save_success', type: Decision.label.capitalize)
    end
  end

  def redirect_location
    authenticated_resource.parent.iri
  end

  def requested_resource_parent; end
end

# frozen_string_literal: true

class DecisionsController < EdgeableController
  skip_before_action :check_if_registered, only: :index

  private

  def authenticated_resource!
    case action_name
    when 'index'
      parent_resource!.last_or_new_decision
    else
      super
    end
  end

  def create_meta
    data = super
    data << [
      authenticated_resource.parent.iri,
      NS::ARGU[:decision],
      authenticated_resource.iri,
      delta_iri(:replace)
    ]
    data
  end

  def index_success_json
    respond_with_resource(resource: parent_resource!.last_decision)
  end

  def active_response_success_message
    if authenticated_resource.argu_publication.published_at.present?
      parent_key = authenticated_resource.parent.model_name.singular
      I18n.t("decisions.#{parent_key}.#{authenticated_resource.state}")
    else
      I18n.t('type_save_success', type: I18n.t('decisions.type').capitalize)
    end
  end

  def new_resource_from_params
    decision = parent_resource!.decisions.unpublished.where(publisher: current_user).first
    decision = super if decision.nil?
    decision
  end

  def redirect_location
    authenticated_resource.parent.iri
  end

  def resource_by_id
    return if action_name == 'new' || action_name == 'create'
    parent_resource!.decisions.find_by(step: params[:id].to_i, root_id: tree_root_id)
  end

  def resource_by_id_parent; end

  def resource_new_params
    super.merge(
      state: params[:state]
    )
  end
end

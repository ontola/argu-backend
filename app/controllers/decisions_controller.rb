# frozen_string_literal: true

class DecisionsController < EdgeableController
  include DecisionsHelper
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

  def create_failure_html
    render action: 'index',
           locals: {decision: authenticated_resource, decisionable: authenticated_resource.parent}
  end

  def create_meta
    data = super
    data << [
      authenticated_resource.parent.iri,
      NS::ARGU[:decision],
      authenticated_resource.iri
    ]
    data
  end

  def edit_success_html
    authenticated_resource.argu_publication.draft! if authenticated_resource.argu_publication.blank?

    render action: 'index',
           locals: {
             decisionable: parent_resource!,
             edit_decision: authenticated_resource
           }
  end

  def index_success_html
    skip_verify_policy_scoped(true)
    render locals: {decisionable: parent_resource!}
  end

  def index_success_js
    skip_verify_policy_scoped(true)
    render 'show', locals: {decision: parent_resource!.last_decision}
  end

  def index_success_json
    respond_with_resource(resource: parent_resource!.last_decision)
  end

  def active_response_success_message
    if authenticated_resource.argu_publication.published_at.present?
      parent_key = authenticated_resource.parent.model_name.singular
      t("decisions.#{parent_key}.#{authenticated_resource.state}")
    else
      t('type_save_success', type: t('decisions.type').capitalize)
    end
  end

  def new_resource_from_params
    decision = parent_resource!.decisions.unpublished.where(publisher: current_user).first
    decision = super if decision.nil?
    decision
  end

  def new_success_html
    render action: 'index',
           locals: {
             decisionable: parent_resource!,
             new_decision: authenticated_resource
           }
  end

  def redirect_location
    authenticated_resource.parent.iri_path
  end

  def resource_by_id
    return if action_name == 'new' || action_name == 'create'
    parent_resource!.decisions.find_by(step: params[:id].to_i, root_id: root_from_params&.uuid)
  end

  def resource_by_id_parent; end

  def resource_new_params
    super.merge(
      state: params[:state]
    )
  end

  def show_success_html
    render action: 'index', locals: {decisionable: authenticated_resource.parent}
  end

  def show_success_js
    render 'show', locals: {decision: authenticated_resource}
  end

  def update_failure_html
    render action: 'index',
           locals: {
             decisionable: resource.parent,
             decision: authenticated_resource
           }
  end
end

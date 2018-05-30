# frozen_string_literal: true

class DecisionsController < EdgeableController
  include Common::Show
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

  def create_respond_failure_html(resource)
    render action: 'index',
           locals: {decision: resource, decisionable: resource.parent_model}
  end

  def edit_respond_success_html(resource)
    resource.argu_publication.draft! if resource.argu_publication.blank?

    render action: 'index',
           locals: {
             decisionable: parent_resource!,
             edit_decision: resource
           }
  end

  def index_respond_success_html
    render locals: {decisionable: parent_resource!}
  end

  def index_respond_success_js
    render 'show', locals: {decision: parent_resource!.last_decision}
  end

  def index_respond_success_json
    respond_with_200(parent_resource!.last_decision, :json)
  end

  def message_success(resource, _)
    if resource.argu_publication.published_at.present?
      parent_key = resource.parent_model.model_name.singular
      t("decisions.#{parent_key}.#{resource.state}")
    else
      t('type_save_success', type: t('decisions.type').capitalize)
    end
  end

  def new_resource_from_params
    decision = parent_resource!.decisions.unpublished.where(publisher: current_user).first
    decision = super if decision.nil?
    decision
  end

  def new_respond_success_html(resource)
    render action: 'index',
           locals: {
             decisionable: parent_resource!,
             new_decision: resource
           }
  end

  def redirect_model_success(resource)
    resource.parent_model.iri(only_path: true).to_s
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

  def show_respond_success_html(resource)
    render action: 'index', locals: {decisionable: resource.parent_model}
  end

  def show_respond_success_js(resource)
    render 'show', locals: {decision: resource}
  end

  def update_respond_failure_html(resource)
    render action: 'index',
           locals: {
             decisionable: resource.parent_model,
             decision: resource
           }
  end
end

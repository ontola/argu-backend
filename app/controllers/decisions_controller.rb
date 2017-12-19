# frozen_string_literal: true

class DecisionsController < EdgeTreeController
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
    resource.edge.argu_publication.draft! if resource.edge.argu_publication.blank?

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

  def parent_from_params(opts = params)
    super || Edge.find_by(owner_type: parent_resource_type(opts).camelcase, id: parent_id_from_params(opts))&.owner
  end

  def message_success(resource, _)
    if resource.edge.argu_publication.published_at.present?
      parent_key = resource.parent_model.model_name.singular
      t("decisions.#{parent_key}.#{resource.state}")
    else
      t('type_save_success', type: t('decisions.type').capitalize)
    end
  end

  def new_resource_from_params
    decision = parent_resource!.decisions.unpublished.where(publisher: current_user).first
    if decision.nil?
      decision = parent_edge
                     .children
                     .new(owner: Decision.new(resource_new_params.merge(decisionable_id: parent_edge.id)))
                     .owner
      decision.build_happening(happened_at: Time.current) if decision.happening.blank?
      decision.edge.build_argu_publication
    end
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
    url_for([resource.parent_model, only_path: true])
  end

  def resource_by_id
    parent_resource!.decisions.find_by(step: params[:id].to_i) unless action_name == 'new' || action_name == 'create'
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      forum: parent_resource!.forum,
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

# frozen_string_literal: true
class DecisionsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  def index
    authorize parent_resource!, :show?
    respond_to do |format|
      format.html do
        render locals: {decisionable: parent_resource!}
      end
      format.json { respond_with_200(parent_resource!.last_decision, :json) }
      format.js   { render 'show', locals: {decision: parent_resource!.last_decision} }
    end
  end

  def show
    respond_to do |format|
      format.html do
        render action: 'index', locals: {decisionable: parent_resource!}
      end
      format.json { respond_with_200(authenticated_resource, :json) }
      format.js   { render 'show', locals: {decision: authenticated_resource} }
    end
  end

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
    resource.edge.argu_publication.draft! unless resource.edge.argu_publication.present?

    render action: 'index',
           locals: {
             decisionable: parent_resource!,
             edit_decision: resource
           }
  end

  def parent_from_params(opts = params)
    super || Edge.find_by(owner_type: parent_resource_type(opts).camelcase, id: parent_id_from_params(opts)).owner
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
      decision.build_happening(happened_at: DateTime.current) unless decision.happening.present?
      decision.edge.build_argu_publication(publish_type: :direct)
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

  def resource_by_id
    parent_resource!.decisions.find_by(step: params[:id].to_i) unless action_name == 'new' || action_name == 'create'
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      forum: parent_resource!.forum,
      state: params[:state]
    )
  end

  def redirect_model_success(resource)
    return super if %w(destroy trash).include?(action_name)
    resource.parent_model
  end

  def update_respond_failure_html(resource)
    render action: 'index',
           locals: {
             decisionable: resource.parent_model,
             decision: resource
           }
  end
end

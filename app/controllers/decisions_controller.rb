# frozen_string_literal: true
class DecisionsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index
  skip_before_action :check_if_member, only: :index

  def index
    respond_to do |format|
      format.html do
        render locals: {decisionable: get_parent_resource}
      end
      format.json { render json: get_parent_resource.last_decision }
      format.js   { render 'show', locals: {decision: get_parent_resource.last_decision} }
    end
  end

  def show
    respond_to do |format|
      format.html do
        render action: 'index', locals: {decisionable: get_parent_resource}
      end
      format.json { render json: authenticated_resource }
      format.js   { render 'show', locals: {decision: authenticated_resource} }
    end
  end

  def edit
    respond_to do |format|
      format.html do
        render action: 'index',
               locals: {
                 decisionable: get_parent_resource,
                 edit_decision: authenticated_resource
               }
      end
    end
  end

  def new
    decision = policy_scope(authenticated_resource!)
    decision.state = params[:state] if params[:state].present?
    decision.build_happening(happened_at: DateTime.current) unless decision.happening.present?

    respond_to do |format|
      format.html do
        render action: 'index',
               locals: {
                 decisionable: get_parent_resource,
                 new_decision: decision
               }
      end
      format.json { render json: decision }
    end
  end

  def create
    create_service.on(:create_decision_successful) do |decision|
      respond_to do |format|
        format.html do
          redirect_to decision.decisionable.owner,
                      notice: t("decisions.#{decision.decisionable.owner.model_name.singular}.#{decision.state}")
        end
        format.json { render json: decision, status: 201, location: decision }
      end
    end
    create_service.on(:create_decision_failed) do |decision|
      respond_to do |format|
        format.html { render action: 'index', locals: {decision: decision, decisionable: decision.decisionable.owner} }
        format.json { render json: decision.errors, status: 422 }
      end
    end
    create_service.commit
  end

  def update
    update_service.on(:update_decision_successful) do |decision|
      respond_to do |format|
        format.html do
          redirect_to decision.decisionable.owner,
                      notice: t('type_save_success', type: t('decisions.type').capitalize)
        end
        format.json { render json: decision.decisionable.owner, status: :updated, location: decision }
      end
    end
    update_service.on(:update_decision_failed) do |decision|
      respond_to do |format|
        format.html do
          render action: 'index',
                 locals: {
                   decisionable: decision.decisionable.owner,
                   decision: decision
                 }
        end
        format.json { render json: decision.errors, status: :unprocessable_entity }
      end
    end
    update_service.commit
  end

  def log
    respond_to do |format|
      format.html { render 'log', locals: {resource: resource_by_id} }
      format.json { render json: resource_by_id.activities }
    end
  end

  private

  def authenticated_resource!
    case action_name
    when 'index'
      resource_by_id
    else
      super
    end
  end

  def get_parent_resource(opts={}, url_params={})
    Edge.find(params[:motion_id]).owner
  end

  def new_resource_from_params
    Edge.find(params[:motion_id])
      .children
      .new(owner: Decision.new(resource_new_params.merge(decisionable: get_parent_resource.edge)))
      .owner
  end

  def permit_params
    params
      .require(:decision)
      .permit(*policy(resource_by_id || new_resource_from_params || Decision).permitted_attributes)
  end

  def resource_by_id
    get_parent_resource.decisions.find_by(step: params[:id].to_i) unless action_name == 'new' || action_name == 'create'
  end

  def resource_new_params
    {
      forum: get_parent_resource.forum,
      state: params[:state]
    }
  end
end

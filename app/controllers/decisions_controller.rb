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
    authenticated_resource!.argu_publication.draft! unless authenticated_resource!.argu_publication.present?

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
    respond_to do |format|
      format.html do
        render action: 'index',
               locals: {
                 decisionable: get_parent_resource,
                 new_decision: authenticated_resource!
               }
      end
      format.json { render json: authenticated_resource! }
    end
  end

  def create
    create_service.on(:create_decision_successful) do |decision|
      respond_to do |format|
        format.html do
          notice = if decision.argu_publication.published_at.present?
                     t("decisions.#{decision.decisionable.owner.model_name.singular}.#{decision.state}")
                   else
                     t('type_save_success', type: t('decisions.type').capitalize)
                   end
          redirect_to decision.decisionable.owner, notice: notice
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

  private

  def authenticated_resource!
    case action_name
    when 'index'
      get_parent_resource.last_or_new_decision
    else
      super
    end
  end

  def get_parent_resource(opts={}, url_params={})
    Edge.find(params[:motion_id]).owner
  end

  def new_resource_from_params
    decision = get_parent_resource.decisions.unpublished.where(publisher: current_user).first
    if decision.nil?
      decision = Edge.find(params[:motion_id])
                   .children
                   .new(owner: Decision.new(resource_new_params.merge(decisionable: get_parent_resource.edge)))
                   .owner
      decision.build_happening(happened_at: DateTime.current) unless decision.happening.present?
      decision.build_argu_publication(publish_type: :direct)
    end
    decision
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
    HashWithIndifferentAccess.new(
      forum: get_parent_resource.forum,
      state: params[:state]
    )
  end
end

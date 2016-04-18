# frozen_string_literal: true
class DecisionsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :authorize_action, only: :index

  def index
    respond_to do |format|
      format.html do
        render locals: {decision: nil, decisionable: authenticated_resource!}
      end
      format.json { render json: decision }
    end
  end

  def show
    decision = resource_by_id
    respond_to do |format|
      format.html { redirect_to motion_decisions_url(decision.decisionable) }
      format.json { render json: decision }
      format.js   { render locals: {decision: decision} }
    end
  end

  def edit
    decision = policy_scope(authenticated_resource!)
    decision.state = params[:state] if params[:state].present?
    decision.build_happening(happened_at: DateTime.current) unless decision.happening.present?
    decision.build_forwarded_to if decision.forwarded? && decision.forwarded_to.nil?

    respond_to do |format|
      format.html do
        render action: 'index', locals: {decision: decision, decisionable: decision.decisionable}
      end
      format.json { render json: decision }
    end
  end

  def update
    update_service.on(:update_decision_successful) do |decision|
      respond_to do |format|
        format.html do
          redirect_to decision.decisionable,
                      notice: t("decisions.#{decision.decisionable.model_name.singular}.#{decision.state}")
        end
        format.json { render json: decision.decisionable, status: :updated, location: decision }
      end
    end
    update_service.on(:update_decision_failed) do |decision|
      respond_to do |format|
        format.html do
          render action: 'edit',
                 locals: {
                   decisionable: decision.decisionable,
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
    params[:action] == 'index' ? get_parent_resource : super
  end

  def permit_params
    params
      .require(:decision)
      .permit(*policy(resource_by_id || new_resource_from_params || Decision).permitted_attributes)
  end
end

# frozen_string_literal: true
class DecisionsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  def index
    authorize get_parent_resource, :show?
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

  def update
    update_service.on(:update_decision_successful) do |decision|
      respond_to do |format|
        format.html do
          redirect_to decision.parent_model,
                      notice: t('type_save_success', type: t('decisions.type').capitalize)
        end
        format.json { render json: decision.parent_model, status: :updated, location: decision }
      end
    end
    update_service.on(:update_decision_failed) do |decision|
      respond_to do |format|
        format.html do
          render action: 'index',
                 locals: {
                   decisionable: decision.parent_model,
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

  def create_respond_blocks_failure(resource, format)
    format.html { render action: 'index', locals: {decision: resource, decisionable: resource.parent_model} }
    format.json { render json: resource.errors, status: :unprocessable_entity }
    format.json_api { render json_api_error(422, resource.errors) }
  end

  def create_respond_blocks_success(resource, format)
    format.html do
      notice = if resource.edge.argu_publication.published_at.present?
                 t("decisions.#{resource.parent_model.model_name.singular}.#{resource.state}")
               else
                 t('type_save_success', type: t('decisions.type').capitalize)
               end
      redirect_to resource.parent_model, notice: notice
    end
    format.json { render json: resource, status: 201, location: resource }
  end

  def edit_respond_blocks_success(resource, _)
    resource.edge.argu_publication.draft! unless resource.edge.argu_publication.present?

    render action: 'index',
           locals: {
             decisionable: get_parent_resource,
             edit_decision: resource
           }
  end

  def get_parent_resource(_opts = {})
    get_parent_edge.owner
  end

  def get_parent_edge(opts = params)
    @parent_edge ||=
      if parent_resource_class(opts).try(:shortnameable?)
        parent_resource_class(opts).find_via_shortname!(parent_id_from_params(opts)).edge
      else
        Edge.find_by!(owner_type: parent_resource_type(opts).camelcase, id: parent_id_from_params(opts))
      end
  end

  def new_resource_from_params
    decision = get_parent_resource.decisions.unpublished.where(publisher: current_user).first
    if decision.nil?
      decision = Edge.find(params[:motion_id])
                     .children
                     .new(owner: Decision.new(resource_new_params.merge(decisionable_id: get_parent_edge.id)))
                     .owner
      decision.build_happening(happened_at: DateTime.current) unless decision.happening.present?
      decision.edge.build_argu_publication(publish_type: :direct)
    end
    decision
  end

  def new_respond_blocks_success(resource, format)
    format.html do
      render action: 'index',
             locals: {
               decisionable: get_parent_resource,
               new_decision: resource
             }
    end
    format.json { render json: resource }
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

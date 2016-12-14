# frozen_string_literal: true
class VotesController < AuthorizedController
  include NestedResourceHelper

  # GET /model/:model_id/vote
  def show
    @model = get_parent_resource

    authorize @model.forum, :show?

    @vote = authenticated_resource

    respond_to do |format|
      format.html { redirect_to url_for([:new, @model, :vote, for: for_param]) }
      format.json { render 'create', location: @vote }
      format.json_api { render json: @vote }
    end
  end

  def new
    @model = get_parent_resource
    authorize @model, :show?

    render locals: {
      resource: @model,
      vote: Vote.new
    }
  end

  # POST /model/:model_id/v/:for
  def create
    @model = get_parent_resource
    get_context

    method = create_service.resource.persisted? ? :update? : :create?
    authorize create_service.resource, method

    if create_service.resource.persisted? && !create_service.resource.for_changed?
      respond_to do |format|
        format.json do
          render status: 304,
                 locals: {model: create_service.resource.parent_model, vote: create_service.resource}
        end
        format.json_api { head 304 }
        format.js { head :not_modified }
        format.html do
          if params[:vote].try(:[], :r).present?
            redirect_to redirect_param
          else
            redirect_to polymorphic_url(create_service.resource.edge.parent.owner),
                        notice: t('votes.alerts.not_modified')
          end
        end
      end
    else
      create_service.on(:create_vote_successful) do |vote|
        respond_to do |format|
          format.json { render location: vote, locals: {model: vote.parent_model, vote: vote} }
          format.json_api { render json: vote }
          format.js { render locals: {model: vote.parent_model, vote: vote} }
          format.html do
            if params[:vote].try(:[], :r).present?
              redirect_to redirect_param
            else
              redirect_to polymorphic_url(vote.edge.parent.owner),
                          notice: t('votes.alerts.success')
            end
          end
        end
      end
      create_service.on(:create_vote_failed) do |vote|
        respond_to do |format|
          format.json { render json: vote.errors, status: 400 }
          format.json_api { render json: vote.errors, status: 400 }
          # format.js { head :bad_request }
          format.html do
            redirect_to polymorphic_url(vote.edge.parent.owner),
                        notice: t('votes.alerts.failed')
          end
        end
      end
      create_service.commit
    end
  end

  def destroy
    vote = Vote.find deserialized_params[:id]
    authorize vote, :destroy?
    respond_to do |format|
      if vote.destroy
        send_event category: 'votes',
                   action: 'destroy',
                   label: vote.for
        format.js do
          render locals: {
            vote: vote
          }
        end
        format.json { head 204 }
      else
        format.js { head :bad_request }
        format.json { head :bad_request }
      end
    end
  end

  def forum_for(url_options)
    voteable = parent_resource_klass(url_options).find_by(id: url_options[parent_resource_key(url_options)])
    voteable.try :forum if voteable.present?
  end

  private

  def authorize_action
    return super unless params[:action] == 'show'
    authorize authenticated_resource.edge.parent.owner, :show?
  end

  def resource_by_id
    return super unless params[:action] == 'show'
    @_resource_by_id ||= Vote.find_by(
      voteable_id: get_parent_resource.id,
      voteable_type: get_parent_resource.class.name,
      voter: current_profile,
      forum: get_parent_resource.forum
    )
  end

  def for_param
    if deserialized_params[:for].is_a?(String) && deserialized_params[:for].present?
      warn '[DEPRECATED] Using direct params is deprecated, please use proper nesting instead.'
      param = deserialized_params[:for]
    elsif deserialized_params[:vote].is_a?(ActionController::Parameters)
      param = deserialized_params[:vote][:for]
    end
    param.present? && param !~ /\D/ ? Vote.fors.key(param.to_i) : param
  end

  def get_context
    @forum = (@vote || @model).forum
  end

  def deserialized_params
    return super if request.format.json_api? && request.method != 'GET'
    params
  end

  def deserialize_params_options
    {keys: {side: :for}}
  end

  def permit_params
    deserialized_params.permit(:id)
  end

  def redirect_param
    params.require(:vote).permit(:r)[:r]
  end

  def redirect_url
    tpl = URITemplate.new("#{url_for([:new, get_parent_resource, :vote, only_path: true])}{?confirm,r,vote%5Bfor%5D}")
    tpl.expand(confirm: true, r: params[:r], 'vote%5Bfor%5D' => for_param)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      publisher: current_user,
      for: for_param
    )
  end
end

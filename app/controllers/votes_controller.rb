# frozen_string_literal: true
class VotesController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def index
    skip_verify_policy_scoped(true)
    respond_to do |format|
      format.json_api do
        render json: get_parent_resource.vote_collection(collection_options),
               include: [:members, views: [:members, views: :members]]
      end
    end
  end

  # GET /model/:model_id/vote
  def show
    respond_to do |format|
      format.html { redirect_to url_for([:new, authenticated_resource.parent_model, :vote, for: for_param]) }
      format.json { render 'create', location: authenticated_resource }
      format.json_api { render json: authenticated_resource }
    end
  end

  def new
    @model = get_parent_resource.voteable
    authorize @model, :show?

    render locals: {
      resource: @model,
      vote: Vote.new
    }
  end

  # POST /model/:model_id/v/:for
  def create
    @model = get_parent_resource

    method = create_service.resource.persisted? ? :update? : :create?
    authorize create_service.resource, method

    if create_service.resource.persisted? && !create_service.resource.for_changed?
      respond_to do |format|
        format.json do
          render status: 304,
                 locals: {model: create_service.resource.parent_model.voteable, vote: create_service.resource}
        end
        format.json_api { head 304 }
        format.js { head :not_modified }
        format.html do
          if params[:vote].try(:[], :r).present?
            redirect_to redirect_param
          else
            redirect_to polymorphic_url(create_service.resource.parent_model.voteable),
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
              redirect_to polymorphic_url(vote.parent_model.voteable),
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
            redirect_to polymorphic_url(vote.parent_model.voteable),
                        notice: t('votes.alerts.failed')
          end
        end
      end
      create_service.commit
    end
  end

  def destroy
    vote = Vote.find params[:id]
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

  def resource_by_id
    return super unless params[:action] == 'show' && params[:motion_id].present?
    @_resource_by_id ||= Vote.find_by(
      voteable_id: get_parent_resource.voteable.id,
      voteable_type: get_parent_resource.voteable.class.name,
      creator: current_profile,
      forum: get_parent_resource.forum
    )
  end

  def for_param
    if params[:for].is_a?(String) && params[:for].present?
      # Still used for upvoting arguments
      warn '[DEPRECATED] Using direct params is deprecated, please use proper nesting instead.'
      param = params[:for]
    elsif params[:vote].is_a?(ActionController::Parameters)
      param = params[:vote][:for]
    end
    param.present? && param !~ /\D/ ? Vote.fors.key(param.to_i) : param
  end

  def get_parent_resource
    @parent_resource ||= super.try(:default_vote_event) || super
  end

  def deserialize_params_options
    {keys: {side: :for}}
  end

  def permit_params
    params.permit(:id)
  end

  def redirect_param
    params.require(:vote).permit(:r)[:r]
  end

  def redirect_url
    tpl = URITemplate.new(
      "#{url_for([:new, get_parent_resource.voteable, :vote, only_path: true])}{?confirm,r,vote%5Bfor%5D}"
    )
    tpl.expand(confirm: true, r: params[:r], 'vote%5Bfor%5D' => for_param)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      publisher: current_user,
      for: for_param
    )
  end
end

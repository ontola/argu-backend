# frozen_string_literal: true
class VotesController < AuthorizedController
  include NestedResourceHelper

  def index
    collection = Collection.new(
      association: :votes,
      group_by: 'http://schema.org/option',
      id: url_for([get_parent_resource, :votes]),
      member: policy_scope(Vote.joins(:edge).where(edges: {parent_id: get_parent_resource.edge.id})),
      parent: get_parent_resource,
      title: 'Votes'
    )
    respond_to do |format|
      format.json_api do
        render json: collection, include: {member: collection.member}
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

  def update
    update_service.on(:update_vote_successful) do
      respond_to do |format|
        format.json_api { head :no_content }
      end
    end
    update_service.on(:update_vote_failed) do |vote|
      respond_to do |format|
        format.json_api { render json_api_error(422, vote.errors) }
      end
    end
    update_service.commit
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
      voter: current_profile,
      forum: get_parent_resource.forum
    )
  end

  def for_param
    param = params[:vote].try(:[], :for)
    param.present? && param !~ /\D/ ? Vote.fors.key(param.to_i) : param
  end

  def get_parent_resource
    @parent_resource ||= super.try(:default_vote_event) || super
  end

  def deserialize_params_options
    {keys: {side: :for}}
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

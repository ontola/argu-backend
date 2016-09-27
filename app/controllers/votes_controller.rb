# frozen_string_literal: true

class VotesController < AuthorizedController
  include NestedResourceHelper

  # GET /model/:model_id/vote
  def show
    @model = get_parent_resource

    authorize @model.forum, :show?

    @vote = Vote.find_by(voteable: @model, voter: current_profile, forum: @model.forum)

    respond_to do |format|
      format.html { redirect_to url_for([:new, @model, :vote, for: for_param]) }
      format.json { render 'create', location: @vote }
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
        format.json { render status: 304, locals: {model: @model, vote: create_service.resource} }
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
          format.json { render location: vote, locals: {model: @model, vote: vote} }
          format.json_api { render json: vote }
          format.js { render locals: {model: @model, vote: vote} }
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
        vote.voteable.reload
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

  def check_if_registered
    return if current_profile.present?
    resource = get_parent_resource
    authorize resource, :show?
    raise Argu::NotAUserError.new(forum: resource.forum, r: redirect_url)
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

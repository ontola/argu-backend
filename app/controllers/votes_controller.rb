# frozen_string_literal: true

class VotesController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_member, only: :destroy

  # GET /model/:model_id/vote
  def show
    @model = get_parent_resource

    authorize @model.forum, :show?

    @vote = Vote.find_by(voteable: @model, voter: current_profile, forum: @model.forum)

    respond_to do |format|
      if current_profile.member_of? @model.forum
        format.html { redirect_to url_for([:new, @model, :vote, for: for_param]) }
        format.json { render 'create', location: @vote }
      else
        format.html { render template: 'forums/join', locals: {forum: @model.forum, r: request.fullpath} }
        format.js { render partial: 'forums/join', layout: false, locals: {forum: @model.forum, r: request.fullpath} }
        format.json { render 'create', location: @vote }
      end
    end
  end

  def new
    @model = get_parent_resource
    authorize @model, :show?
    authorize Vote.new(voteable: @model,
                       voter: current_profile,
                       forum: @model.forum)

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
        format.js { head :not_modified }
        format.html do
          redirect_to polymorphic_url(create_service.resource.edge.parent.owner),
                      notice: t('votes.alerts.not_modified')
        end
      end
    else
      create_service.on(:create_vote_successful) do |vote|
        respond_to do |format|
          format.json { render location: vote, locals: {model: @model, vote: vote} }
          format.js
          format.html do
            redirect_to polymorphic_url(vote.edge.parent.owner),
                        notice: t('votes.alerts.success')
          end
        end
      end
      create_service.on(:create_vote_failed) do |vote|
        respond_to do |format|
          format.json { render json: vote.errors, status: 400 }
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
    vote = Vote.find params[:id]
    authorize vote, :destroy?

    respond_to do |format|
      if vote.destroy
        vote.voteable.reload
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

  def check_if_member
    resource = get_parent_resource
    if current_profile.present? && !current_profile.member_of?(resource.forum)
      options = {
        forum: resource.forum,
        r: redirect_url
      }
      if request.format == 'json'
        options[:body] = {
          error: 'NO_MEMBERSHIP',
          membership_url: forum_memberships_url(get_parent_resource.forum, redirect: false)
        }
      end
      raise Argu::NotAMemberError.new(options)
    end
  end

  def check_if_registered
    if current_profile.blank?
      resource = get_parent_resource
      authorize resource, :show?
      raise Argu::NotAUserError.new(forum: resource.forum, r: redirect_url)
    end
  end

  def for_param
    if params[:for].is_a?(String) && params[:for].present?
      warn '[DEPRECATED] Using direct params is deprecated, please use proper nesting instead.'
      params[:for]
    elsif params[:vote].is_a?(Hash)
      params[:vote][:for]
    end
  end

  def get_context
    @forum = (@vote || @model).forum
  end

  def permit_params
    params.permit(:id, :for)
  end

  def query_payload(opts = {})
    query = opts.merge(vote: {for: for_param})
    query.to_query
  end

  def redirect_url
    redirect_url = URI.parse(url_for([:new, get_parent_resource, :vote, only_path: true]))
    redirect_url.query = query_payload(confirm: true)
    redirect_url
  end

  def resource_new_params
    {
      for: for_param
    }
  end
end

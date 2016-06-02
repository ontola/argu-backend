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

    @vote = Vote.find_or_initialize_by(voteable: @model, voter: current_profile, publisher: current_user)
    @vote.forum ||= @model.forum

    if @vote.persisted?
      authorize @vote, :update?
    else
      authorize @vote, :create?
    end

    respond_to do |format|
      if @vote.for == for_param
        format.json { render status: 304 }
        format.js { head :not_modified }
        format.html { redirect_to polymorphic_url(@model), notice: t('votes.alerts.not_modified') }
      elsif @vote.update(for: for_param)
        create_activity_with_cleanup @vote,
                                     action: :create,
                                     parameters: {for: @vote.for},
                                     recipient: @vote.voteable,
                                     owner: current_profile,
                                     forum_id: @vote.forum.id
        @model.reload
        save_vote_to_stats @vote
        format.json { render location: @vote }
        format.js
        format.html { redirect_to polymorphic_url(@model), notice: t('votes.alerts.success') }
      else
        format.json { render json: @vote.errors, status: 400 }
        # format.js { head :bad_request }
        format.html { redirect_to polymorphic_url(@model), notice: t('votes.alerts.failed') }
      end
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

  # @return [Model] parent The vote, or if it doesn't exists yet, the parent on which the Vote is created.
  def authenticated_resource!
    params[:id].present? ? Vote.find(params[:id]) : get_parent_resource
  end

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
      raise Argu::NotAUserError.new(resource.forum, redirect_url)
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

  def query_payload(opts = {})
    query = opts.merge(vote: {for: for_param})
    query.to_query
  end

  def redirect_url
    redirect_url = URI.parse(url_for([:new, get_parent_resource, :vote, only_path: true]))
    redirect_url.query = query_payload(confirm: true)
    redirect_url
  end

  # noinspection RubyUnusedLocalVariable
  def save_vote_to_stats(vote)
    # TODO: @implement this
  end
end

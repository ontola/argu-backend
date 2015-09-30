class VotesController < AuthenticatedController
  skip_before_action :check_if_member, only: :destroy

  # GET /model/:model_id/vote
  def show
    @model = get_voteable

    authorize @model.forum, :show?

    @vote = Vote.find_by(voteable: @model, voter: current_profile, forum: @model.forum)

    respond_to do |format|
      if current_profile.member_of? @model.forum
        format.html { redirect_to url_for([:new, @model, :vote, for: for_param]) }
        format.json { render 'create', location: @vote }
      else
        format.html { render template: 'forums/join', locals: { forum: @model.forum, r: request.fullpath } }
        format.js { render partial: 'forums/join', layout: false, locals: { forum: @model.forum, r: request.fullpath } }
        format.json { render 'create', location: @vote }
      end
    end
  end

  def new
    @model = get_voteable
    authorize @model, :show?

    render locals: {
               resource: @model,
               vote: Vote.new
           }
  end

  # POST /model/:model_id/v/:for
  def create
    @model = get_voteable
    get_context

    authorize @model.forum, :show?

    @vote = Vote.find_or_initialize_by(voteable: @model, voter: current_profile, forum: @model.forum)

    respond_to do |format|
      if @vote.for == for_param
        format.json { render status: 304 }
        format.js { head :not_modified }
        format.html { redirect_to polymorphic_url(@model), notice: t('votes.alerts.not_modified') }
      elsif @vote.update(for: for_param)
        create_activity_with_cleanup @vote, action: :create, parameters: {for: @vote.for}, recipient: @vote.voteable, owner: current_profile, forum_id: @vote.forum.id
        @model.reload
        save_vote_to_stats @vote
        format.json { render location: @vote }
        format.js
        format.html { redirect_to polymorphic_url(@model), notice: t('votes.alerts.success') }
      else
        format.json { render json: @vote.errors, status: 400 }
        format.js { head :bad_request }
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
        format.js { render locals: {
                               vote: vote
                           } }
        format.json { head 204 }
      else
        format.js { head :bad_request }
        format.json { head :bad_request }
      end
    end
  end

  def self.forum_for(url_options)
    voteable = voteable_klass(url_options).find_by(id: url_options[voteable_key(url_options)])
    voteable.try :forum if voteable.present?
  end

  def get_voteable
    voteable_class.find params[voteable_param]
  end

  private

  def authenticated_resource!
    get_voteable
  end

  def check_if_member
    resource = get_voteable
    if current_profile.present? && !current_profile.member_of?(resource.forum)
      options = {
          forum: resource.forum,
          r: redirect_url
      }
      if request.format == 'json'
        options[:body] = {
            error: 'NO_MEMBERSHIP',
            membership_url: forum_memberships_url(get_voteable.forum, redirect: false)
        }
      end
      raise Argu::NotAMemberError.new(options)
    end
  end

  def check_if_registered
    if current_profile.blank?
      resource = get_voteable
      authorize resource, :show?
      raise Argu::NotAUserError.new(resource.forum, redirect_url)
    end
  end

  def for_param
    if params[:vote].is_a?(Hash)
      params[:vote][:for]
    elsif params[:for].is_a?(String)
      warn '[DEPRECATED] Using direct params is deprecated, please use proper nesting instead.'
      params[:for]
    else
      nil
    end
  end

  def get_context
    @forum = @model.forum
  end

  def query_payload(opts = {})
    query = opts.merge({vote: {for: for_param}})
    query.to_query
  end

  def redirect_url
    redirect_url = URI.parse(url_for([:new, get_voteable, :vote, only_path: true]))
    redirect_url.query = query_payload(confirm: true)
    redirect_url
  end

  # noinspection RubyUnusedLocalVariable
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

  def voteable_class
    VotesController.voteable_klass(request.path_parameters)
  end

  def self.voteable_key(hash)
    hash.keys.find { |k| /_id/ =~ k }
  end

  # Note: Safe to constantize since `path_parameters` uses the routes for naming.
  def self.voteable_klass(opts = nil)
    voteable_type(opts).capitalize.constantize
  end

  def voteable_param
    VotesController.voteable_key(request.path_parameters)
  end

  def self.voteable_type(opts = nil)
    voteable_key(opts)[0..-4]
  end

end

class VotesController < ApplicationController

  # GET /model/:model_id/vote
  def show
    @model = voteable_class.find params[voteable_param]

    if current_profile.blank?
      authorize @model, :show?
      render_register_modal(nil)
    else
      authorize @model.forum, :show?

      @vote = Vote.find_by(voteable: @model, voter: current_profile, forum: @model.forum)

      respond_to do |format|
        if current_profile.member_of? @model.forum
          format.json { render 'create', location: @vote }
        else
          format.html { render template: 'forums/join', locals: { forum: @model.forum, r: request.fullpath } }
          format.js { render partial: 'forums/join', layout: false, locals: { forum: @model.forum, r: request.fullpath } }
          format.json { render 'create', location: @vote }
        end
      end
    end
  end

  def new
    @model = voteable_class.find params[voteable_param]
    authorize @model, :show?
    redirect_to url_for(@model)
  end

  # POST /model/:model_id/v/:for
  def create
    @model = voteable_class.find params[voteable_param]
    get_context

    if current_profile.blank?
      authorize @model, :show?
      render_register_modal(nil)
    else
      authorize @model.forum, :show?

      @vote = Vote.find_or_initialize_by(voteable: @model, voter: current_profile, forum: @model.forum)

      respond_to do |format|
        if !current_profile.member_of? @model.forum
          format.js { render partial: 'forums/join', layout: false, locals: { forum: @model.forum, r: request.fullpath } }
          format.html { render template: 'forums/join', locals: { forum: @model.forum, r: request.fullpath } }
        elsif @vote.for == params[:for]
          format.json { render status: :not_modified }
          format.js { head :not_modified }
          format.html { redirect_to @model, notice: t('votes.alerts.not_modified') }
        elsif @vote.update(for: params[:for])
          create_activity_with_cleanup @vote, action: :create, parameters: {for: @vote.for}, recipient: @vote.voteable, owner: current_profile, forum_id: @vote.forum.id
          @model.reload
          save_vote_to_stats @vote
          format.json { render location: @vote }
          format.js
          format.html { redirect_to @model, notice: t('votes.alerts.success') }
        else
          format.json { render json: @vote.errors, status: :bad_request }
          format.js { head :bad_request }
          format.html { redirect_to @model, notice: t('votes.alerts.failed') }
        end
      end
    end
  end

  def voteable_class
    VotesController.voteable_klass(request.path_parameters)
  end

  def voteable_param
    VotesController.voteable_key(request.path_parameters)
  end

  def self.voteable_key(hash)
    hash.keys.find { |k| /_id/ =~ k }
  end

  def self.voteable_type(opts = nil)
    voteable_key(opts)[0..-4]
  end

  # Note: Safe to constantize since `path_parameters` uses the routes for naming.
  def self.voteable_klass(opts = nil)
    voteable_type(opts).capitalize.constantize
  end

  def self.forum_for(url_options)
    voteable = voteable_klass(url_options).find_by(id: url_options[voteable_key(url_options)])
    voteable.try :forum if voteable.present?
  end

private
  def get_context
    @forum = @model.forum
  end

  # noinspection RubyUnusedLocalVariable
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

end

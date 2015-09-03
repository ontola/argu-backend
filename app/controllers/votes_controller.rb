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

      @vote = Vote.find_or_initialize_by(voteable: @model, voter: current_profile)

      respond_to do |format|
        if !current_profile.member_of? current_forum
          format.json { render status: 403, json: { error: 'NO_MEMBERSHIP', membership_url: forum_memberships_url(current_forum, redirect: false) } }
          format.js { render partial: 'forums/join', layout: false, locals: { forum: current_forum, r: request.fullpath } }
          format.html { render template: 'forums/join', locals: { forum: current_forum, r: request.fullpath } }
        elsif @vote.for == params[:for]
          format.json { render status: 304 }
          format.js { head :not_modified }
          format.html { redirect_to polymorphic_url(@model), notice: t('votes.alerts.not_modified') }
        elsif @vote.update(for: params[:for])
          create_activity_with_cleanup @vote, action: :create, parameters: {for: @vote.for}, recipient: @vote.voteable, owner: current_profile, forum_id: current_forum.id
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
    @forum = current_forum
  end

  # noinspection RubyUnusedLocalVariable
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

end

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


private
  def get_context
    @forum = @model.forum
  end

  # noinspection RubyUnusedLocalVariable
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

  def voteable_param
    request.path_parameters.keys.find { |k| /_id/ =~ k }
  end

  def voteable_type
    voteable_param[0..-4]
  end

  # Note: Safe to constantize since `path_parameters` uses the routes for naming.
  def voteable_class
    voteable_type.capitalize.constantize
  end

end

class VotesController < ApplicationController
  # POST /model/:model_id/vote/:for
  def create
    if params[:argument_id].present?
      @model = Argument.find params[:argument_id]
    elsif params[:motion_id].present?
      @model = Motion.find params[:motion_id]
    end
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
          format.html { redirect_to @model, notice: t('votes.alerts.not_modified') }
          format.js { head :not_modified }
          format.json { render json: @vote, status: :not_modified }
        elsif @vote.update(for: params[:for])
          create_activity @vote, action: :create, parameters: {for: @vote.for}, recipient: @vote.voteable, owner: current_profile, forum_id: @vote.forum.id
          @model.reload
          save_vote_to_stats @vote
          format.html { redirect_to @model, notice: t('votes.alerts.success') }
          format.js
          format.json { render json: @vote, status: :created, location: @vote }
        else
          format.html { redirect_to @model, notice: t('votes.alerts.failed') }
          format.js { head :bad_request }
          format.json { render json: @vote.errors, status: :bad_request }
        end
      end
    end
  end


private
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

end
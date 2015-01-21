class VotesController < ApplicationController
  # POST /model/:model_id/vote/:for
  def create
    if params[:argument_id].present?
      @model = Argument.find params[:argument_id]
    elsif params[:motion_id].present?
      @model = Motion.find params[:motion_id]
    end
    authorize @model.forum, :show?

    respond_to do |format|
      if !current_profile.member_of? @model.forum
        format.js { render partial: 'forums/join', layout: false, locals: { forum: @model.forum, r: request.fullpath } }
        format.html { render template: 'forums/join', locals: { forum: @model.forum, r: request.fullpath } }
      elsif (@vote = Vote.find_or_create_by(voteable: @model, voter: current_profile, forum: @model.forum)).update(for: params[:for])
        @model.reload
        save_vote_to_stats @vote
        format.html { redirect_to @model, notice: '_Successfully voted_' }
        format.js
        format.json { render json: @vote, status: :created, location: @vote }
      else
        format.html { redirect_to @model, notice: '_Vote failed_' }
        format.js { head :bad_request }
        format.json { render json: @vote.errors, status: :bad_request }
      end
    end
  end


private
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

end
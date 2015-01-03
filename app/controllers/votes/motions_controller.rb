class Votes::MotionsController < ApplicationController
  # POST /motions/:motion_id/vote/:for
  def create
    @motion = Motion.find(params[:motion_id])
    authorize @motion, :vote?
    if params[:for].in?(Vote.fors)
      @vote = Vote.find_or_create_by(voteable: @motion, voter: current_profile, forum: @motion.forum)
      if @vote.try(:for) == permit_params[:for]
        respond_to do |format|
          format.json { render json: {notifications: [{type: 'warning', message: '_Stem ongewijzigd_'}]} }
        end
      else
        if @vote.update(for: permit_params[:for])
          save_vote_to_stats(@vote)
          @voted = permit_params[:for]
          respond_to do |format|
            format.js # create.js.erb
            format.json { render json: {notifications: [{type: 'success', message: '_Gelukt_'}]} }
          end
        else
          render_error(@vote.errors)
        end
      end
    else
      render_error('_Ongeldige aanvraag_')
    end
  end

  # DELETE /motions/:motion_id/vote
  def destroy
    @motion = Motion.find(params[:motion_id])
    @vote = Vote.find_or_create_by(voteable: @motion, voter: current_profile)
    authorize @motion, :vote?
    if @vote.update for: :abstain
      save_vote_to_stats(@vote)
      respond_to do |format|
        format.json { render json: {notifications: [{type: 'success', message: '_Gelukt_'}]} }
      end
    else
      respond_to do |format|
        format.json { render json: {notifications: [{type: 'error', message: t('status.400')}] } }
      end
    end
  end

private
  def permit_params
    params.permit :for, :motion_id
  end

  def render_error(message = nil)
    respond_to do |format|
      format.json { render json: {notifications: [{type: 'error', message: message || t('status.400')}] } }
    end
  end

  def save_vote_to_stats(vote)
    #TODO: @implement this
  end
end
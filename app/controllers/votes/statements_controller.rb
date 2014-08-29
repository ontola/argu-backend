class Votes::StatementsController < ApplicationController
  # POST /statements/:statement_id/vote/:for
  def create
    @statement = Statement.find(params[:statement_id])
    authorize @statement, :vote?
    if params[:for].in?(Vote.fors)
      @vote = Vote.find_or_create_by(voteable: @statement, voter: current_user)
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
          render_error
        end
      end
    else
      render_error
    end
  end

  # DELETE /statements/:statement_id/vote
  def destroy
    @statement = Statement.find(params[:statement_id])
    authorize! :vote, Statement
    @vote = Vote.find_or_create_by(voteable: @statement, voter: current_user)
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
    params.permit :for, :statement_id
  end

  def render_error
    respond_to do |format|
      format.json { render json: {notifications: [{type: 'error', message: t('status.400')}] } }
    end
  end

  def save_vote_to_stats(vote)
    #TODO: @implement this
  end
end
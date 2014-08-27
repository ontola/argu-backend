class Votes::ArgumentsController < ApplicationController
  # POST /arguments/:statement_id/vote/:for
  def create
    @argument = Argument.find(params[:argument_id])
    authorize! :vote, @argument
    respond_to do |format|
      @voted = Vote.find_or_create_by voteable: @argument, voter: current_user
      if (@voted.blank? || !@voted.for.eql?(:pro)) && (@voted = @voted.update(for: :pro))
        save_vote_to_stats @voted
        format.html { redirect_to @argument.statement, notice: 'Successfully voted.' }
        format.js
        format.json { render json: @voted, status: :created, location: @voted }
      else
        format.html { render action: "new" }
        format.js { render status: :bad_request }
        format.json { render json: @voted.errors, status: :bad_request }
      end
    end
  end

  # DELETE /arguments/:statement_id/vote
  def destroy
    @argument = Argument.find(params[:argument_id])
    authorize! :vote, @argument
    @voted = Vote.find_or_create_by voteable: @argument, voter: current_user
    if @voted.present? && @voted.for?(:pro) && @voted.update(for: :abstain)
      save_vote_to_stats @voted
      respond_to do |format|
        format.html { redirect_to @argument.statement, notice: '_Successfully unvoted._' }
        format.js
        format.json { render json: {notifications: [{type: 'success', message: '_Gelukt_'}]} }
      end
    else
      respond_to do |format|
        format.html { redirect_to @argument.statement, notice: '_error._' }
        format.json { render json: {notifications: [{type: 'error', message: t('status.400')}] } }
      end
    end
  end

private
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

end
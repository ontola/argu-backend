class Votes::ArgumentsController < ApplicationController
  # POST /arguments/:motion_id/vote/:for
  def create
    @argument = Argument.find(params[:argument_id])
    authorize @argument, :vote?
    respond_to do |format|
      @voted = Vote.find_or_create_by voteable: @argument, voter: current_profile, forum: @argument.forum
      if (@voted.blank? || !@voted.for.eql?(:pro)) && (@voted = @voted.update(for: :pro))
        save_vote_to_stats @voted
        format.html { redirect_to @argument.motion, notice: 'Successfully voted.' }
        format.js
        format.json { render json: @voted, status: :created, location: @voted }
      else
        format.html { render action: "new" }
        format.js { render status: :bad_request }
        format.json { render json: @voted.errors, status: :bad_request }
      end
    end
  end

  # DELETE /arguments/:motion_id/vote
  def destroy
    @argument = Argument.find(params[:argument_id])
    authorize @argument, :vote?
    @voted = Vote.find_or_create_by voteable: @argument, voter: current_profile
    if @voted.present? && @voted.for?(:pro) && @voted.update(for: :abstain)
      save_vote_to_stats @voted
      respond_to do |format|
        format.html { redirect_to @argument.motion, notice: '_Successfully unvoted._' }
        format.js
        format.json { render json: {notifications: [{type: 'success', message: '_Gelukt_'}]} }
      end
    else
      respond_to do |format|
        format.html { redirect_to @argument.motion, notice: '_error._' }
        format.js { head 400 }
        format.json { render json: {notifications: [{type: 'error', message: t('status.400')}] } }
      end
    end
  end

private
  def save_vote_to_stats(vote)
    #TODO: @implement this
  end

end
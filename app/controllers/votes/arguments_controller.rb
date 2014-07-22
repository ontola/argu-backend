class Votes::ArgumentsController < ApplicationController
  # POST /arguments/:statement_id/vote/:for
  def create
    @argument = Argument.find(params[:argument_id])
    authorize! :vote, Argument
    respond_to do |format|
      @voted = Avote.where(voteable: @argument, voter: current_user).last.try(:for)
      if (@voted.blank? || @voted.eql?('abstain')) && (@voted = Avote.create(for: :pro, voteable: @argument, voter: current_user))
        format.html { redirect_to @argument.statement, notice: 'Successfully voted.' }
        format.js
        format.json { render json: @voted, status: :created, location: @voted }
      else
        format.html { render action: "new" }
        format.js
        format.json { render json: @voted.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/:statement_id/vote
  def destroy
    @argument = Argument.find(params[:argument_id])
    authorize! :vote, Argument
    if @argument && Avote.create(for: :abstain, voteable: @argument, voter: current_user)
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

end
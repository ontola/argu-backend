class VotesController < ApplicationController
  # POST /votes
  # POST /votes.json
  def create
    @argument = Argument.find_by_id(params[:argument_id])

    respond_to do |format|
      if current_user.vote_for(@argument)
        format.html { redirect_to @argument.statement, notice: 'Successfully voted.' }
        format.js
        format.json { render json: @vote, status: :created, location: @vote }
      else
        format.html { render action: "new" }
        format.js
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /votes/1
  # DELETE /votes/1.json
  def destroy
    @argument = Argument.find_by_id(params[:argument_id])
    current_user.unvote_for(@argument)

    respond_to do |format|
      format.html { redirect_to @argument.statement, notice: 'Successfully unvoted.' }
      format.js
      format.json { head :no_content }
    end
  end
end

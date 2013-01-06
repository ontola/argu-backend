class VotesController < ApplicationController
  #load_and_authorize_resource

  # GET /votes/1
  # GET /votes/1.json
  def show
    @argument = Argument.find_by_id(@vote.argument_id)
    @s = @sa.statement.title 

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vote }
    end
  end

  # GET /votes/new
  # GET /votes/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vote }
    end
  end

  # GET /votes/1/edit
  def edit
  end

  # POST /votes
  # POST /votes.json
  def create
    @argument = Argument.find_by_id(params[:id])

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
    @argument = Argument.find_by_id(params[:id])
    current_user.unvote_for(@argument)

    respond_to do |format|
      format.html { redirect_to @argument.statement, notice: 'Successfully unvoted.' }
      format.js
      format.json { head :no_content }
    end
  end
end

class VotesController < ApplicationController
  load_and_authorize_resource

  # GET /votes
  # GET /votes.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @votes }
    end
  end

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
    @vote.user_id = params[:user_id] unless params[:user_id].nil?
    @vote.argument_id = params[:argument_id] unless params[:argument_id].nil?
    @argument = Argument.find_by_id(@vote.argument_id)

    respond_to do |format|
      if @vote.save
        format.html { redirect_to :back, notice: 'Successfully voted.' }
        format.js
        format.json { render json: @vote, status: :created, location: @vote }
      else
        format.html { render action: "new" }
        format.js
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /votes/1
  # PUT /votes/1.json
  def update
    respond_to do |format|
      if @vote.update_attributes(params[:vote])
        format.html { redirect_to @vote, notice: 'vote was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /votes/1
  # DELETE /votes/1.json
  def destroy
    @argument = Argument.find_by_id(@vote.argument_id)
    @vote.destroy

    respond_to do |format|
      format.html { redirect_to votes_url }
      format.js
      format.json { head :no_content }
    end
  end
end

class VotesController < ApplicationController
  # GET /votes
  # GET /votes.json
  def index
    @votes = Vote.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @votes }
    end
  end

  # GET /votes/1
  # GET /votes/1.json
  def show
    @vote = Vote.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vote }
    end
  end

  # GET /votes/new
  # GET /votes/new.json
  def new
    @vote = Vote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vote }
    end
  end

  # GET /votes/1/edit
  def edit
    @vote = Vote.find(params[:id])
  end

  # POST /votes
  # POST /votes.json
  def create
    if signed_in?
      @vote = Vote.new(params[:vote])
      @vote.user_id = params[:user_id] unless params[:user_id].nil?
      @vote.statementargument_id = params[:statementargument_id] unless params[:statementargument_id].nil?
      @statementargument = Statementargument.find_by_id(@vote.statementargument_id)

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
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + " (Not signed in)!"
        format.html { redirect_to votes_url}
        format.json { head :no_content }
      end
    end
  end

  # PUT /votes/1
  # PUT /votes/1.json
  def update
    if signed_in?
      @vote = Vote.find(params[:id])

      respond_to do |format|
        if @vote.update_attributes(params[:vote])
          format.html { redirect_to @vote, notice: 'vote was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @vote.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + "!"
        format.html { redirect_to votes_url}
        format.json { head :no_content }
      end
    end
  end

  # DELETE /votes/1
  # DELETE /votes/1.json
  def destroy
    if signed_in?
      @vote = Vote.find(params[:id])
      @statementargument = Statementargument.find_by_id(@vote.statementargument_id)
      @vote.destroy

      respond_to do |format|
        format.html { redirect_to votes_url }
        format.js
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + "!"
        format.html { redirect_to votes_url}
        format.js
        format.json { head :no_content }
      end
    end
  end
end

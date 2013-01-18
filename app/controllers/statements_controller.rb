class StatementsController < ApplicationController
  load_and_authorize_resource

  #autocomplete :argument, :title, :full => true, :extra_data => [:id] #Not currently in use

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.first(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statements }
    end
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
    #@arguments = Argument.where(statement_id: @statement.id).order('votes.size DESC')
    @arguments = @statement.arguments.plusminus_tally({order: "vote_count ASC"})
    @pro = Array.new
    @con = Array.new
    unless @arguments.nil?
      @arguments.each do |arg|
        if arg.pro?
          @pro << arg
        else
          @con << arg
        end
      end
    end
    

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/revisions/:rev
  # GET /statements/1/revisions/:rev.json
  def revisions
    authorize! :read, :revisions
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    
    if @statement.nil?
      @statement = @statement.versions.last
    end

    respond_to do |format|
      format.html # revisions.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/revisions
  # GET /statements/1/revisions.json
  def allrevisions
    authorize! :index, :revisions
    @statement = Statement.find(params[:id])
    @revisions = @statement.versions

    respond_to do |format|
      format.html # allrevisions.html.erb
      format.json { render json: @statement }
    end
  end  

  # PUT /statements/1/revisions
  # PUT /statements/1/revisions.json
  def setrevision
    authorize :update, :revisions
    @statement = Statement.find(params[:id])
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    
    if @statement.nil?
      @statement = @statement.versions.last
    end

    respond_to do |format|
      if @statement.save
        format.html { redirect_to @statement, notice: 'Statement was successfully restored.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end  

  # GET /statements/new
  # GET /statements/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/edit
  def edit
  end

  # POST /statements
  # POST /statements.json
  def create
    respond_to do |format|
      if @statement.save
        format.html { redirect_to @statement, notice: 'Statement was successfully created.' }
        format.json { render json: @statement, status: :created, location: @statement }
      else
        format.html { render action: "new" }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /statements/1
  # PUT /statements/1.json
  def update
    respond_to do |format|
      if @statement.update_attributes(params[:statement])
        format.html { redirect_to @statement, notice: 'Statement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement.destroy

    respond_to do |format|
      format.html { redirect_to statements_url }
      format.json { head :no_content }
    end
  end
end

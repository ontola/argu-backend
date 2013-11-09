class StatementsController < ApplicationController
  load_and_authorize_resource

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.page(params[:page])

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
    @statement = Statement.find_by_id(params[:statement_id])
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    
    if @statement.nil?
      @statement = @statement.versions.last
    end

    authorize! :revisions, @statement
    respond_to do |format|
      format.html # revisions.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/revisions
  # GET /statements/1/revisions.json
  def allrevisions
    @statement = Statement.find_by_id(params[:statement_id])
    @revisions = @statement.versions.scoped.reject{ |v| v.object.nil? }.reverse

    authorize! :allrevisions, @statement
    respond_to do |format|
      format.html # allrevisions.html.erb
      format.json { render json: @statement }
    end
  end  

  # PUT /statements/1/revisions
  # PUT /statements/1/revisions.json
  def setrevision
    @statement = Statement.find_by_id(params[:statement_id])
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    
    if @statement.nil?
      @statement = @statement.versions.last
    end

    authorize :setrevision, @statement
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

  def tagged
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:tag])
    if params[:tag].present? 
      @statements = Statement.tagged_with(params[:tag])
    else
      @statements = Statement.postall
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
    @statement.add_mod current_user

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

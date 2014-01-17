class StatementsController < ApplicationController

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.page(params[:page])
    authorize! :read, Statement
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statements }
    end
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
  	# Eager loading and filtering on trashed on both the main and the tally query seems to result in the least amount of sql
  	# without writing a custom query 
    @statement = Statement.find_by_id params[:id] #, arguments: {is_trashed: false}).includes(:arguments, :tags).first
    authorize! :read, Statement
    @arguments = @statement.arguments.where(is_trashed: false).plusminus_tally({order: "vote_count ASC"}).group_by { |a| a.key }

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

    unless (@rev = params[:rev]).nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    @statement ||= @statement.versions.last

    authorize! :revisions, @statement
    respond_to do |format|
      format.html # revisions.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/revisions
  # GET /statements/1/revisions.json
  def allrevisions
    @statement = Statement.where(id: params[:statement_id], arguments: {is_trashed: true}).includes(:arguments).first
    @revisions = @statement.versions.scoped.reject{ |v| v.object.nil? }.reverse
    @arguments = @statement.arguments.where(is_trashed: true).plusminus_tally({order: "vote_count ASC"}).group_by { |a| a.key }

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

    unless (@rev = params[:rev]).nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    @statement ||= @statement.versions.last if @statement.nil?

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
    authorize! :read, Statement
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:tag])
    if params[:tag].present? 
      @statements = Statement.tagged_with(params[:tag]) # TODO rewrite statement to exclude where statement.tag_id
    else
      @statements = Statement.postall
    end
  end

  # GET /statements/new
  # GET /statements/new.json
  def new
    authorize! :create, Statement
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/edit
  def edit
    @statement = Statement.find_by_id(params[:id])
    authorize! :update, @statement
  end

  # POST /statements
  # POST /statements.json
  def create
    authorize! :create, Statement
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
    @statement = Statement.find_by_id params[:id]
    authorize! :update, @statement
    respond_to do |format|
      if @statement.update_attributes(params[:statement])
        if params[:statement].present? && params[:statement][:tag_id].present? && @statement.tags.reject { |a,b| a.statement==b }.first.present?
          format.html { redirect_to tagged_url(tag: ActsAsTaggableOn::Tag.find_by_id(@statement.tag_id).name)}
          format.json { head :no_content }
        else
          format.html { redirect_to @statement, notice: 'Statement was successfully updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render action: "edit" }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement = Statement.find_by_id params[:id]
    if params[:destroy] == 'true'
      authorize! :destroy, @statement
      @statement.destroy
    else
      authorize! :trash, @statement
      @statement.trash
    end

    respond_to do |format|
      format.html { redirect_to statements_url }
      format.json { head :no_content }
    end
  end
end

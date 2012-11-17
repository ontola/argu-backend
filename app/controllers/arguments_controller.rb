class ArgumentsController < ApplicationController
  load_and_authorize_resource
  
  # GET /arguments
  # GET /arguments.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arguments }
    end
  end

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @offset = params[:offset].to_i
    @offset ||= 0
    
    @comments = @argument.root_comments.order('created_at ASC').offset(@offset).limit(5)
    @length = @argument.root_comments.length

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @argument }
    end
  end


  # GET /arguments/1/revisions/:rev
  # GET /arguments/1/revisions/:rev.json
  def revisions
    authorize! :read, :revisions
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @argument.versions.find_by_id(@rev);
      @argument = @version.reify
    end
    
    if @argument.nil?
      @argument = @argument.versions.last
    end

    respond_to do |format|
      format.html # revisions.html.erb
      format.json { render json: @argument }
    end
  end

  # GET /arguments/1/revisions
  # GET /arguments/1/revisions.json
  def allrevisions
    authorize! :index, :revisions
    @argument = Argument.find(params[:id])
    @revisions = @argument.versions

    respond_to do |format|
      format.html # allrevisions.html.erb
      format.json { render json: @argument }
    end
  end  

  # PUT /arguments/1/revisions
  # PUT /arguments/1/revisions.json
  def setrevision
    authorize! :update, :revisions
    @argument = Argument.find(params[:id])
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @argument.versions.find_by_id(@rev);
      @argument = @version.reify
    end
    
    if @argument.nil?
      @argument = @argument.versions.last
    end

    respond_to do |format|
      if @argument.save
        format.html { redirect_to @argument, notice: 'Argument was successfully restored.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end  


  # GET /arguments/new
  # GET /arguments/new.json
  def new
    @statement_id = params[:statement_id]
    @pro = params[:pro]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @argument }
    end
  end

  # GET /arguments/1/edit
  def edit
  end

  # POST /arguments
  # POST /arguments.json
  def create
    @argument.statement_id = params[:statement_id]
    @argument.pro = params[:pro]
    respond_to do |format|
      if @argument.save
        format.html { redirect_to (params[:statement_id].blank? ? @argument : Statement.find_by_id(params[:statement_id])), notice: 'Argument was successfully created.' }
        format.json { render json: @argument, status: :created, location: @argument }
      else
        format.html { render action: "new", pro: params[:pro], statement_id: params[:statement_id] }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    respond_to do |format|
      if @argument.update_attributes(params[:argument])
        format.html { redirect_to @argument, notice: 'Argument was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def destroy
    @argument.destroy

    respond_to do |format|
      format.html { redirect_to arguments_url }
      format.json { head :no_content }
    end
  end

  def placeComment 
    @comment = params[:comment]
    @comment = Comment.build_from( Argument.find(params[:id]), @current_user.id, @comment )
    @comment.save!
    @comment.move_to_child_of(Comment.find_by_id(params[:parent_id])) unless params[:parent_id].blank?
    redirect_to request.referrer
  end

end

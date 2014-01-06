class ArgumentsController < ApplicationController
  load_and_authorize_resource :argument, :parent => false

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @parent_id = params[:parent_id].to_s
    
    @comments = @argument.root_comments.where(is_trashed: false).page(params[:page]).order('created_at ASC')
    @length = @argument.root_comments.length

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @argument }
    end
  end


  # GET /arguments/1/revisions/:rev
  # GET /arguments/1/revisions/:rev.json
  def revisions
    @argument = Argument.find_by_id(params[:argument_id])
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @argument.versions.find_by_id(@rev);
      @argument = @version.reify
    end
    
    if @argument.nil?
      @argument = @argument.versions.last
    end

    authorize! :revisions, @argument
    respond_to do |format|
      format.html # revisions.html.erb
      format.json { render json: @argument }
    end
  end

  # GET /arguments/1/revisions
  # GET /arguments/1/revisions.json
  def allrevisions
    @argument = Argument.find_by_id(params[:argument_id])
    @revisions = @argument.versions.scoped.reject{ |v| v.object.nil? }.reverse

    authorize! :revisions, @argument
    respond_to do |format|
      format.html # allrevisions.html.erb
      format.json { render json: @argument }
    end
  end  

  # PUT /arguments/1/revisions
  # PUT /arguments/1/revisions.json
  def setrevision
    @argument = Argument.find_by_id(params[:argument_id])
    @version = nil
    @rev = params[:rev]

    unless @rev.nil?
      @version = @argument.versions.find_by_id(@rev);
      @argument = @version.reify
    end
    
    if @argument.nil?
      @argument = @argument.versions.last
    end

    authorize! :revisions, @argument
    respond_to do |format|
      if @argument.save
        format.html { redirect_to @argument, notice: t("arguments.notices.restored") }
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
    @argument.assign_attributes({pro: params[:pro], statement_id: params[:statement_id]})
    #@argument.statement = Statement.find_by_id!(params[:statement_id]).id.to_s
    #@argument.pro = params[:pro] == 'true' ? true : false
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
    respond_to do |format|
      if @argument.save
        format.html { redirect_to (params[:argument][:statement_id].blank? ? @argument : Statement.find_by_id(params[:argument][:statement_id])), notice: t("arguments.notices.created") }
        format.json { render json: @argument, status: :created, location: @argument }
      else
        format.html { render action: "new", pro: params[:pro], statement_id: params[:argument][:statement_id] }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    respond_to do |format|
      if @argument.update_attributes(params[:argument])
        format.html { redirect_to @argument, notice: t("arguments.notices.updated") }
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
    if params[:destroy] == 'true'
      authorize! :destroy, @argument
      @argument.destroy
    else
      authorize! :trash, @argument
      @argument.trash
    end

    respond_to do |format|
      format.html { redirect_to @argument.statement }
      format.json { head :no_content }
    end
  end

  # POST /arguments/1/comments
  def placeComment 
    argument = Argument.find(params[:argument_id])
    @comment = params[:comment]
    @comment = Comment.build_from(argument, @current_user.id, @comment )
    @comment.save!
    
    unless params[:parent_id].blank?
      parent = Comment.find_by_id(params[:parent_id])
      org_parent = parent
      for i in 0..10 do
        if parent.parent.present? && (parent = parent.parent).parent.blank? # Stack isn't too deep, so allow
          break
        end
      end
      if i < 10
        @comment.move_to_child_of(org_parent)
      else
        @comment.move_to_child_of(org_parent.parent)
      end
    end

    redirect_to argument_path(argument)
  end

  # DELETE /arguments/1/comments/1
  def destroyComment
  	@comment = Comment.find_by_id params[:comment_id]
    if params[:destroy] == 'true'
      authorize! :destroy, @comment
      @comment.destroy
    else
      authorize! :trash, @comment
      @comment.trash
    end
    respond_to do |format|
    	format.html { redirect_to argument_path(@comment.commentable_id) }
    	format.js # destroy_comment.js
    end
  end

end

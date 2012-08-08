class ArgumentsController < ApplicationController
  # GET /arguments
  # GET /arguments.json
  def index
    @arguments = Argument.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arguments }
    end
  end

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @argument = Argument.find(params[:id])
    @comments = @argument.root_comments

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @argument }
    end
  end

  # GET /arguments/new
  # GET /arguments/new.json
  def new
    @argument = Argument.new	

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @argument }
    end
  end

  # GET /arguments/1/edit
  def edit
    @argument = Argument.find(params[:id])
  end

  # POST /arguments
  # POST /arguments.json
  def create
    if signed_in?
      raise PermissionViolation unless Argument.creatable_by?(current_user)
      if !params[:statement_id].nil?
        @sa = Statementargument.create(Statement.find_by_id(params[:statement_id]), @argument)
      end
      @argument = Argument.new(params[:argument])
      if !params[:content].nil?
        @argument.content = params[:content]
      end

      respond_to do |format|
        if @argument.save
          format.html { redirect_to @argument, notice: 'Argument was successfully created.' }
          format.json { render json: @argument, status: :created, location: @argument }
        else
          format.html { render action: "new" }
          format.json { render json: @argument.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + "!"
        format.html { redirect_to statements_url}
        format.json { head :no_content }
      end
    end
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    if signed_in?
      @argument = Argument.find(params[:id])
      raise PermissionViolation unless @argument.updatable_by?(current_user)

      respond_to do |format|
        if @argument.update_attributes(params[:argument])
          format.html { redirect_to @argument, notice: 'Argument was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @argument.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + "!"
        format.html { redirect_to statements_url}
        format.json { head :no_content }
      end
    end
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def destroy
    if signed_in?
      @argument = Argument.find(params[:id])
      raise PermissionViolation unless @argument.destroyable_by?(current_user)

      @argument.destroy

      respond_to do |format|
        format.html { redirect_to arguments_url }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        flash.now[:error] = t(:application_general_not_allowed) + "!"
        format.html { redirect_to statements_url}
        format.json { head :no_content }
      end
    end
  end

  def placeComment 
    @comment = params[:comment]
    @comment = Comment.build_from( Argument.find(params[:id]), @current_user.id, @comment )
    @comment.save!
    redirect_to request.referrer
  end

end

class ArgumentsController < ApplicationController

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @argument = Argument.includes(:comment_threads).find params[:id]
    authorize @argument
    current_context @argument
    @parent_id = params[:parent_id].to_s
    
    @comments = @argument.comment_threads.where(:parent_id => nil, is_trashed: false).page(params[:page]).order('created_at ASC')
    @length = @argument.root_comments.length

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @argument }
      format.json { render json: @argument }
    end
  end

  # GET /arguments/new
  # GET /arguments/new.json
  def new
    @argument = Argument.new
    authorize @argument
    current_context @argument
    @argument.assign_attributes({pro: %w(con pro).index(params[:pro]), motion_id: params[:motion_id]})

    respond_to do |format|
      if params[:motion_id].present?
        format.html { render :form }
        format.json { render json: @argument }
      else
        format.html { render text: 'Bad request', status: 400 }
        format.json { head 400 }
      end
    end
  end

  # GET /arguments/1/edit
  def edit
    @argument = Argument.find params[:id]
    authorize @argument

    respond_to do |format|
      format.html { render :form}
    end
  end

  # POST /arguments
  # POST /arguments.json
  def create
    @argument = Argument.new argument_params
    @argument.creator = current_profile
    authorize @argument
    @argument.motion_id = argument_params[:motion_id]
    @argument.pro = argument_params[:pro]

    respond_to do |format|
      if @argument.save
        format.html { redirect_to (argument_params[:motion_id].blank? ? @argument : Motion.find_by_id(argument_params[:motion_id])), notice: 'Argument was successfully created.' }
        format.json { render json: @argument, status: :created, location: @argument }
      else
        format.html { render action: "form", pro: argument_params[:pro], motion_id: argument_params[:motion_id] }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    @argument = Argument.find params[:id]
    authorize @argument

    respond_to do |format|
      if @argument.update_attributes(argument_params)
        format.html { redirect_to @argument, notice: t("arguments.notices.updated") }
        format.json { head :no_content }
      else
        format.html { render :form }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def destroy
    @argument = Argument.find params[:id]
    if params[:destroy].to_s == 'true'
      authorize @argument
      @argument.destroy
    else
      authorize @argument, :trash?
      @argument.trash
    end

    respond_to do |format|
      format.html { redirect_to motion_path(@argument.motion_id) }
      format.json { head :no_content }
    end
  end

private
  def argument_params
    params.require(:argument).permit :title, :content, :pro, :motion_id
  end

end

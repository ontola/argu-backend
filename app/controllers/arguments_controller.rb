class ArgumentsController < AuthenticatedController

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @forum = @argument.forum
    current_context @argument
    @parent_id = params[:parent_id].to_s
    
    @comments = @argument.filtered_threads(show_trashed?, params[:page])
    @length = @argument.root_comments.length
    @vote = Vote.find_by(voteable: @argument, voter: current_profile)

    respond_to do |format|
      format.html { render locals: {
                               comment: Comment.new
                           } }
      format.widget { render @argument }
      format.json { render json: @argument }
    end
  end

  # GET /arguments/new
  # GET /arguments/new.json
  def new
    @forum = Forum.find_via_shortname params[:forum_id]
    @argument = @forum.arguments.new motion_id: params[:motion_id]

    authorize @argument, :new?
    current_context @argument
    @argument.assign_attributes({pro: %w(con pro).index(params[:pro]) })

    respond_to do |format|
      if params[:motion_id].present?
        format.js { render js: "window.location = #{request.url.to_json}" }
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
    authorize @argument, :edit?
    current_context @argument
    @forum = @argument.forum

    respond_to do |format|
      format.html { render :form}
    end
  end

  # POST /arguments
  # POST /arguments.json
  def create
    set_tenant(authenticated_resource!)
    @ca = CreateArgument.new current_profile,
                             argument_params.merge({
                                 forum: @forum,
                                 publisher: current_user
                             }),
                             {
                               auto_vote: params[:argument][:auto_vote] == 'true' && current_profile == current_user.profile
                             }
    authorize @ca.resource, :create?
    @ca.subscribe(ActivityListener.new)
    @ca.subscribe(MailerListener.new)
    @ca.on(:create_argument_successful) do |argument|
      respond_to do |format|
        argument = argument_params[:motion_id].blank? ? argument : argument.motion
        format.html { redirect_to argument, notice: t('arguments.notices.created') }
        format.json { render json: argument, status: :created, location: argument }
      end
    end
    @ca.on(:create_argument_failed) do |argument|
      respond_to do |format|
        format.html { render action: 'form',
                             locals: {argument: argument} }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    @ca.commit
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    @argument = Argument.find params[:id]
    authorize @argument, :update?

    respond_to do |format|
      if @argument.update_attributes(argument_params)
        format.html { redirect_to @argument, notice: t('arguments.notices.updated') }
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
      authorize @argument, :destroy?
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
  def authorize_show
    @argument = Argument.includes(:comment_threads).find params[:id]
    authorize @argument, :show?
  end

  def argument_params
    params.require(:argument).permit(*policy(@argument || Argument).permitted_attributes)
  end

  def self.forum_for(url_options)
    Argument.find_by(url_options[:argument_id] || url_options[:id]).try(:forum)
  end

  def set_tenant(item)
    @forum = item.forum
  end

end

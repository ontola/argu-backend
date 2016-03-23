class ArgumentsController < AuthorizedController
  # GET /arguments/1
  # GET /arguments/1.json
  def show
    # @forum = @argument.forum
    # @parent_id = params[:parent_id].to_s

    @comments = @argument.filtered_threads(show_trashed?, params[:page])
    @length = @argument.root_comments.length
    @vote = Vote.find_by(voteable: @argument, voter: current_profile)

    respond_to do |format|
      format.html do
        render locals: {
          comment: Comment.new
        }
      end
      format.widget { render @argument }
      format.json { render json: @argument }
    end
  end

  # GET /arguments/new
  # GET /arguments/new.json
  def new
    authenticated_resource!.assign_attributes({pro: %w(con pro).index(params[:pro]) })

    respond_to do |format|
      if params[:motion_id].present?
        format.js { render js: "window.location = #{request.url.to_json}" }
        format.html { render :form, locals: { argument: authenticated_resource! } }
        format.json { render json: @argument }
      else
        format.html { render text: 'Bad request', status: 400 }
        format.json { head 400 }
      end
    end
  end

  # GET /arguments/1/edit
  def edit
    respond_to do |format|
      format.html { render :form }
    end
  end

  # POST /arguments
  # POST /arguments.json
  def create
    create_service.subscribe(ActivityListener.new)
    create_service.on(:create_argument_successful) do |argument|
      respond_to do |format|
        argument = permit_params[:motion_id].blank? ? argument : argument.motion
        format.html { redirect_to argument, notice: t('arguments.notices.created') }
        format.json { render json: argument, status: :created, location: argument }
      end
    end
    create_service.on(:create_argument_failed) do |argument|
      respond_to do |format|
        format.html { render action: 'form',
                             locals: {argument: argument} }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    create_service.commit
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    respond_to do |format|
      if authenticated_resource!.update_attributes(argument_params)
        format.html { redirect_to authenticated_resource!, notice: t('arguments.notices.updated') }
        format.json { head :no_content }
      else
        format.html { render :form }
        format.json { render json: authenticated_resource!.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arguments/1/untrash
  # PUT /arguments/1/untrash.json
  def untrash
    respond_to do |format|
      if authenticated_resource!.untrash
        format.html { redirect_to authenticated_resource!, notice: t('type_untrash_success', type: t('arguments.type')) }
        format.json { head :no_content }
      else
        format.html { render :form, notice: t('errors.general') }
        format.json { render json: authenticated_resource!.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def destroy
    if authenticated_resource!.is_trashed?
      if params[:destroy].present? && params[:destroy] == 'true'
        authenticated_resource!.destroy
        flash[:notice] = t('type_destroy_success',
                           type: t('arguments.type'))
      end
    else
      authenticated_resource!.trash
      flash[:notice] = t('type_trash_success',
                         type: t('arguments.type'))
    end

    respond_to do |format|
      format.html { redirect_to motion_path(authenticated_resource!.motion_id) }
      format.json { head :no_content }
    end
  end

  def forum_for(url_options)
    argument_id = url_options[:argument_id] || url_options[:id]
    if argument_id.presence
      Argument.find_by(id: argument_id).try(:forum)
    elsif url_options[:forum_id].present?
      Forum.find_via_shortname_nil url_options[:forum_id]
    end
  end

  private

  def authorize_show
    @argument = Argument.includes(:comment_threads).find params[:id]
    authorize @argument, :show?
  end

  def create_service
    @create_service ||= CreateArgument.new(
        current_profile,
        permit_params.merge(
            forum: authenticated_context,
            publisher: current_user
        ),
        {
            auto_vote: params[:argument][:auto_vote] == 'true' && current_profile == current_user.profile
        })
  end

  def permit_params
    params.require(:argument).permit(*policy(@argument || Argument).permitted_attributes)
  end

  def resource_new_params
    super.merge(
      motion_id: params[:motion_id]
    )
  end
end

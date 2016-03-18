class ProjectsController < AuthorizedController
  prepend_before_action :redirect_pages, only: :show

  def new
    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def create
    @cp = CreateProject.new(
      current_profile,
      permit_params.merge(resource_new_params))

    authorize @cp.resource, :create?
    @cp.subscribe(ActivityListener.new)

    @cp.on(:create_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project }
        format.json { render json: project, status: 201, location: project }
      end
    end
    @cp.on(:create_project_failed) do |project|
      respond_to do |format|
        format.html { render :new, locals: {project: project} }
        format.json { render json: project.errors, status: 422 }
      end
    end
    @cp.commit
  end

  def show
    questions = policy_scope(authenticated_resource!.questions.trashed(show_trashed?))

    motions_without_questions = policy_scope(Motion.where(forum: authenticated_context,
                                                          project: authenticated_resource!,
                                                          question_id: nil,
                                                          is_trashed: show_trashed?))

    @items = (questions + motions_without_questions).sort_by(&:updated_at).reverse if policy(authenticated_resource!).show?

    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource!, include: %w(phases blog_posts) }
    end
  end

  def edit
    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def update
    @up = UpdateProject.new(
      authenticated_resource!,
      permit_params)

    authorize @up.resource, :update?

    @up.on(:update_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project }
        format.json { render json: project, status: 200, location: project }
      end
    end
    @up.on(:update_project_failed) do |project|
      respond_to do |format|
        format.html { render :new, locals: {project: project} }
        format.json { render json: project.errors, status: 422 }
      end
    end
    @up.commit
  end

  # PUT /projects/1/untrash
  # PUT /projects/1/untrash.json
  def untrash
    @project = Project.find params[:id]
    respond_to do |format|
      if @project.untrash
        format.html { redirect_to @project, notice: t('type_untrash_success', type: t('projects.type')) }
        format.json { head :no_content }
      else
        format.html { render :form, notice: t('errors.general') }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find params[:id]
    if @project.is_trashed?
      if params[:destroy].present? && params[:destroy] == 'true'
        authorize @project
        @project.destroy
        flash[:notice] = t('type_destroy_success',
                           type: t('projects.type'))
      end
    else
      authorize @project, :trash?
      @project.trash
      flash[:notice] = t('type_trash_success',
                         type: t('projects.type'))
    end

    respond_to do |format|
      format.html { redirect_to @project.forum }
      format.json { head :no_content }
    end
  end

  private

  def permit_params
    params.require(:project).permit(*policy(authenticated_resource || @project || Project).permitted_attributes)
  end

  def redirect_pages
    if params[:id].to_i == 0
      redirect_to page_path(params[:id])
    end
  end
end

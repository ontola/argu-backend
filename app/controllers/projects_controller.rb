class ProjectsController < AuthorizedController
  include NestedResourceHelper
  prepend_before_action :redirect_pages, only: :show

  def new
    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def create
    create_service.on(:create_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project }
        format.json { render json: project, status: 201, location: project }
      end
    end
    create_service.on(:create_project_failed) do |project|
      respond_to do |format|
        format.html { render :new, locals: {project: project} }
        format.json { render json: project.errors, status: 422 }
      end
    end
    create_service.commit
  end

  def show
    questions = policy_scope(authenticated_resource!.questions
                               .includes(:edge, :default_cover_photo)
                               .published
                               .trashed(show_trashed?))

    motions = policy_scope(authenticated_resource!.motions
                               .includes(:edge, :default_cover_photo, :votes)
                               .published
                               .trashed(show_trashed?))

    if policy(authenticated_resource!).show?
      @items = (questions + motions)
                 .sort_by(&:updated_at)
                 .reverse
    end

    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource!, include: %w(phases blog_posts) }
    end
  end

  def edit
    if authenticated_resource!.argu_publication.try(:published_at).present?
      authenticated_resource!.argu_publication.schedule!
    else
      authenticated_resource!.argu_publication.draft!
      authenticated_resource!.argu_publication.published_at = DateTime.current
    end

    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  def update
    update_service.on(:update_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project }
        format.json { render json: project, status: 200, location: project }
      end
    end
    update_service.on(:update_project_failed) do |project|
      respond_to do |format|
        format.html { render :new, locals: {project: project} }
        format.json { render json: project.errors, status: 422 }
      end
    end
    update_service.commit
  end

  # DELETE /projects/1?destroy=true
  # DELETE /projects/1.json?destroy=true
  def destroy
    destroy_service.on(:destroy_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project.forum, notice: t('type_destroy_success', type: t('projects.type')) }
        format.json { head :no_content }
      end
    end
    destroy_service.on(:destroy_project_failed) do |project|
      respond_to do |format|
        format.html { redirect_to project, notice: t('errors.general') }
        format.json { render json: project.errors, status: :unprocessable_entity }
      end
    end
    destroy_service.commit
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def trash
    trash_service.on(:trash_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project.forum, notice: t('type_trash_success', type: t('projects.type')) }
        format.json { head :no_content }
      end
    end
    trash_service.on(:trash_project_failed) do |project|
      respond_to do |format|
        format.html { redirect_to project, notice: t('errors.general') }
        format.json { render json: project.errors, status: :unprocessable_entity }
      end
    end
    trash_service.commit
  end

  # PUT /projects/1/untrash
  # PUT /projects/1/untrash.json
  def untrash
    untrash_service.on(:untrash_project_successful) do |project|
      respond_to do |format|
        format.html { redirect_to project, notice: t('type_untrash_success', type: t('projects.type')) }
        format.json { head :no_content }
      end
    end
    untrash_service.on(:untrash_project_failed) do |project|
      respond_to do |format|
        format.html { redirect_to project, notice: t('errors.general') }
        format.json { render json: project.errors, status: :unprocessable_entity }
      end
    end
    untrash_service.commit
  end

  private

  def new_resource_from_params
    resource = super
    resource.build_argu_publication(publish_type: 'direct', published_at: DateTime.current)
    resource
  end

  def permit_params
    params
      .require(:project)
      .permit(*policy(resource_by_id || new_resource_from_params || Project).permitted_attributes)
  end

  def redirect_pages
    redirect_to page_path(params[:id]) if params[:id].to_i == 0
  end

  def resource_new_params
    super.merge(start_date: DateTime.current)
  end
end

# frozen_string_literal: true

class ProjectsController < EdgeableController
  prepend_before_action :redirect_pages, only: :show

  def show
    questions = policy_scope(authenticated_resource!.questions
                               .includes(:edge, :default_cover_photo, :motions)
                               .published
                               .show_trashed(show_trashed?))

    motions = policy_scope(authenticated_resource!.motions
                               .where(question_id: nil)
                               .includes(:edge, :default_cover_photo, :votes)
                               .published
                               .show_trashed(show_trashed?))

    if policy(authenticated_resource!).show?
      @items = (questions + motions)
                 .sort_by(&:updated_at)
                 .reverse
    end

    respond_to do |format|
      format.html { render locals: {project: authenticated_resource!} }
      format.json { render json: authenticated_resource!, include: %w[phases blog_posts] }
    end
  end

  private

  def redirect_pages
    redirect_to page_path(params[:id]) if params[:id].to_i.zero?
  end

  def resource_new_params
    super.merge(start_date: Date.current)
  end
end

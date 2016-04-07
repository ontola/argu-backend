class PhasesController < AuthorizedController
  def show
    respond_to do |format|
      format.html { render locals: {phase: @resource} }
      format.json { render json: @resource }
      format.js   { render locals: {phase: @resource} }
    end
  end

  def edit
    respond_to do |format|
      format.html { render locals: {phase: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
    end
  end

  # Set virtual attribute finish_phase to true to update end_date to Time.current
  def update
    update_service.subscribe(ActivityListener.new)
    update_service.on(:update_phase_successful) do |phase|
      respond_to do |format|
        format.html { redirect_to phase.project, notice: t('type_save_success', type: t('projects.phases.type')) }
        format.json { head :no_content }
      end
    end
    update_service.on(:update_phase_failed) do |phase|
      respond_to do |format|
        format.html { render :edit, locals: {phase: phase} }
        format.json { render json: phase.errors, status: :unprocessable_entity }
      end
    end
    update_service.commit
  end

  private

  def permit_params
    params.require(:phase).permit(*policy(@resource || Phase).permitted_attributes)
  end

  def update_service
    @update_service ||= UpdatePhase.new(
        resource_by_id,
        permit_params)
  end
end

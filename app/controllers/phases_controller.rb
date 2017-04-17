# frozen_string_literal: true
class PhasesController < EdgeTreeController
  def show
    respond_to do |format|
      format.html { render locals: {phase: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
      format.js   { render locals: {phase: authenticated_resource!} }
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
    update_service.on(:update_phase_successful) do |phase|
      respond_to do |format|
        format.html { redirect_to phase.parent_model, notice: t('type_save_success', type: t('projects.phases.type')) }
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
    params.require(:phase).permit(*policy(resource_by_id).permitted_attributes)
  end
end

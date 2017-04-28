# frozen_string_literal: true
class PhasesController < EdgeTreeController
  def show
    respond_to do |format|
      format.html { render locals: {phase: authenticated_resource!} }
      format.json { render json: authenticated_resource! }
      format.js   { render locals: {phase: authenticated_resource!} }
    end
  end

  private

  def permit_params
    params.require(:phase).permit(*policy(resource_by_id).permitted_attributes)
  end

  def redirect_model_success(resource)
    super unless action_name == 'update'
    resource.parent_model
  end
end

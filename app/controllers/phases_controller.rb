# frozen_string_literal: true

class PhasesController < EdgeTreeController
  def show
    respond_to do |format|
      format.html { render locals: {phase: authenticated_resource!} }
      format.json { respond_with_200(authenticated_resource!, :json) }
      format.json_api { respond_with_200(authenticated_resource!, :json_api) }
      format.js { render locals: {phase: authenticated_resource!} }
    end
  end

  private

  def redirect_model_success(resource)
    super unless action_name == 'update'
    resource.parent_model
  end
end

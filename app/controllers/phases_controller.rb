# frozen_string_literal: true

class PhasesController < EdgeableController
  def show
    respond_to do |format|
      format.html { render locals: {phase: authenticated_resource!} }
      format.js { render locals: {phase: authenticated_resource!} }
    end
  end

  private

  def redirect_model_success(resource)
    super unless action_name == 'update'
    resource.parent_model.iri(only_path: true).to_s
  end
end

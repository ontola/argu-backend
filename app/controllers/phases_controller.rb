class PhasesController < AuthorizedController
  def show
    respond_to do |format|
      format.html { render locals: {phase: @resource} }
      format.json { render json: @resource }
      format.js   { render locals: {phase: @resource} }
    end
  end
end

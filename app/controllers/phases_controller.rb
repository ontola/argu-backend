class PhasesController < AuthorizedController

  def show
    respond_to do |format|
      format.html { render locals: {phase: @resource} }
      format.json { render json: @resource }
    end
  end

end

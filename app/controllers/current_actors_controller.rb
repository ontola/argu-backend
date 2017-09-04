# frozen_string_literal: true

class CurrentActorsController < ApplicationController
  def show
    respond_to do |format|
      format.json { respond_with_200(current_actor, :json) }
      format.json_api { render json: current_actor, include: %i[profile_photo user actor] }
    end
  end
end

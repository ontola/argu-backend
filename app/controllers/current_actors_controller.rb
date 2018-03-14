# frozen_string_literal: true

class CurrentActorsController < ApplicationController
  def show
    respond_to do |format|
      format.json { respond_with_200(current_actor, :json) }
      format.json_api { render json: current_actor, include: include_show }
      Common::RDF_CONTENT_TYPES.each do |type|
        format.send(type) { render type => current_actor, include: include_show }
      end
    end
  end

  private

  def include_show
    %i[profile_photo user actor]
  end
end

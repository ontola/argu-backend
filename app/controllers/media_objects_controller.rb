# frozen_string_literal: true
class MediaObjectsController < AuthorizedController
  def show
    respond_to do |format|
      format.json { render json: resource_by_id }
      format.json_api { render json: resource_by_id }
    end
  end
end

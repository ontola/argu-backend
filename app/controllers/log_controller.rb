# frozen_string_literal: true
class LogController < AuthorizedController
  include NestedResourceHelper

  def show
    respond_to do |format|
      format.html { render 'log', locals: {resource: authenticated_resource!} }
      format.json do
        respond_with_200(authenticated_resource!.activities, :json)
      end
      format.json_api do
        respond_with_200(authenticated_resource!.activities, :json_api)
      end
    end
  end

  private

  def authorize_action
    authorize authenticated_resource, :log?
  end

  def resource_by_id
    Edge.find(params[:edge_id]).owner
  end
end

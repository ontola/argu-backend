# frozen_string_literal: true
class LogController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :authorize_action

  def show
    respond_to do |format|
      format.html { render 'log', locals: {resource: authenticated_resource!} }
      format.json { render json: authenticated_resource!.activities }
    end
  end

  private

  def authorize_show
    authorize authenticated_resource, :log?
  end

  def resource_by_id
    Edge.find(params[:edge_id]).owner
  end
end

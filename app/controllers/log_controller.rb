# frozen_string_literal: true

class LogController < ParentableController
  private

  def authorize_action
    authorize authenticated_resource, :log?
  end

  def resource_by_id
    Edge.find_by(id: params[:edge_id]).owner
  end

  def show_respond_success_html(resource)
    render 'log', locals: {resource: resource}
  end

  def show_respond_success_json(resource)
    respond_with_200(resource.activities, :json)
  end

  def show_respond_success_serializer(resource, format)
    respond_with_200(resource.activities, format)
  end
end

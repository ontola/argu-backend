# frozen_string_literal: true

class LogsController < ParentableController
  private

  def authorize_action
    authorize authenticated_resource, :log?
  end

  def resource_by_id
    parent_resource
  end

  def show_success_json
    respond_with_collection(collection: authenticated_resource.activities)
  end

  def show_success_json_api
    respond_with_collection(collection: authenticated_resource.activities)
  end

  def show_success_rdf
    respond_with_collection(collection: authenticated_resource.activities)
  end
end

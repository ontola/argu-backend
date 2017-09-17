# frozen_string_literal: true

class MediaObjectsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def show
    respond_to do |format|
      format.json { respond_with_200(resource_by_id, :json) }
      format.json_api { respond_with_200(resource_by_id, :json_api) }
    end
  end

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource, :index_children?, [controller_name, about: parent_resource]
  end

  def index_collection_association
    'attachment_collection'
  end
end

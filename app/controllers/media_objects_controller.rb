# frozen_string_literal: true
class MediaObjectsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def index
    skip_verify_policy_scoped(true)
    respond_to do |format|
      format.json_api do
        render json: get_parent_resource.attachment_collection(collection_options),
               include: [:members, views: [:members, views: :members]]
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: resource_by_id }
      format.json_api { render json: resource_by_id }
    end
  end
end

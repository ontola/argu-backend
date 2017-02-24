# frozen_string_literal: true
class ListItemsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def index
    skip_verify_policy_scoped(true)
    authorize get_parent_resource, :show?

    respond_to do |format|
      format.json_api do
        render json: get_parent_resource
                       .send("#{params[:relationship].to_s.singularize}_collection", collection_options)
      end
    end
  end
end

# frozen_string_literal: true

class VoteMatchesController < ServiceController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index
  skip_before_action :authorize_action, only: :index

  def show
    respond_to do |format|
      format.json { respond_with_200(authenticated_resource, :json) }
      format.json_api { respond_with_200(authenticated_resource, :json_api) }
      format.n3 { respond_with_200(authenticated_resource, :n3) }
    end
  end

  private

  def create_service_parent
    nil
  end

  def index_respond_blocks_success(_, format)
    collection =
      if parent_id_from_params(params).present?
        parent_resource!.vote_match_collection(collection_options)
      else
        Collection.new(
          association_class: VoteMatch,
          user_context: user_context,
          page: params[:page],
          pagination: true
        )
      end
    format.json_api do
      render json: collection,
             include: inc_nested_collection
    end
    format.n3 do
      render n3: collection,
             include: inc_nested_collection
    end
  end

  def redirect_model_success(resource)
    return super if resource.persisted? || !resource.parent_model.is_a?(GuestUser)
    root_path
  end

  def resource_by_id
    return super if params[:page_id].nil? && params[:user_id].nil? || @_resource_by_id.present?
    @_resource_by_id ||= VoteMatch.find_by(creator: parent_resource!.profile, shortname: params[:id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      publisher: current_user
    )
  end
end

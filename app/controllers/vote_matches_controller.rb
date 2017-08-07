# frozen_string_literal: true
class VoteMatchesController < ServiceController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def show
    respond_to do |format|
      format.json { respond_with_200(authenticated_resource, :json) }
      format.json_api { respond_with_200(authenticated_resource, :json_api) }
    end
  end

  private

  def create_service_parent
    nil
  end

  def index_respond_blocks_success(_, format)
    collection =
      if parent_resource.present?
        parent_resource.vote_match_collection(collection_options)
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
             include: INC_NESTED_COLLECTION
    end
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

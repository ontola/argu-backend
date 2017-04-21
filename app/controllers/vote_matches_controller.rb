# frozen_string_literal: true
class VoteMatchesController < ServiceController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def show
    respond_to do |format|
      format.json_api do
        render json: authenticated_resource
      end
    end
  end

  def update
    update_service.on(:update_vote_match_successful) do
      respond_to do |format|
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
    update_service.on(:update_vote_match_failed) do |vote_match|
      respond_to do |format|
        format.json { render json: vote_match.errors, status: :unprocessable_entity }
        format.json_api { render json_api_error(422, vote_match.errors) }
      end
    end
    update_service.commit
  end

  def destroy
    destroy_service.on(:destroy_vote_match_successful) do
      respond_to do |format|
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
    destroy_service.on(:destroy_vote_match_failed) do
      respond_to do |format|
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
    destroy_service.commit
  end

  private

  def get_parent_resource
    super if current_resource_is_nested?
  end

  def create_service
    @create_service ||= CreateVoteMatch.new(
      nil,
      attributes: resource_new_params.merge(permit_params.to_h),
      options: service_options
    )
  end

  def index_respond_blocks_success(_, format)
    collection =
      if get_parent_resource.present?
        get_parent_resource.vote_match_collection(collection_options)
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

  def new_resource_from_params
    VoteMatch.new(publisher: current_user, creator: current_profile)
  end

  def resource_by_id
    return super if params[:page_id].nil? && params[:user_id].nil? || @_resource_by_id.present?
    @_resource_by_id ||= VoteMatch.find_by(creator: get_parent_resource.profile, shortname: params[:id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      publisher: current_user
    )
  end
end

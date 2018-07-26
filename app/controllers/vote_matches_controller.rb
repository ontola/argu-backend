# frozen_string_literal: true

class VoteMatchesController < ServiceController
  skip_before_action :check_if_registered, only: :index
  skip_before_action :authorize_action, only: :index

  private

  def create_service_parent
    nil
  end

  def current_forum
    @current_forum ||= parent_resource.try(:ancestor, :forum)
  end

  def index_collection
    if parent_id_from_params(params).present?
      parent_resource!.vote_match_collection(collection_options)
    else
      @collection ||= ::Collection.new(
        association_class: VoteMatch,
        user_context: user_context
      )
    end
  end

  def redirect_location
    return super if authenticated_resource.persisted? || !authenticated_resource.parent.is_a?(GuestUser)
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

# frozen_string_literal: true

class FeedController < AuthorizedController
  include VotesHelper
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: %i[index]

  helper_method :activities, :relevant_only

  private

  def activities
    @activities ||=
      policy_scope(authenticated_resource.activities)
        .where('activities.created_at < ?', from_time)
        .order('activities.created_at DESC')
        .includes(trackable: :root)
        .limit(10)
  end

  def authorize_action
    authorize feed_resource, :feed?
  end

  def tree_root_id
    @tree_root_id ||= feed_resource&.root_id
  end

  def collect_banners; end

  def feed_resource
    parent_resource
  end

  def from_time
    return Time.current if params[:from_time].blank?
    begin
      Time.parse(params[:from_time]).utc.to_s
    rescue ArgumentError
      Time.current
    end
  end

  def index_collection
    resource_by_id.activity_collection(collection_options)
  end

  def index_respond_success_html
    preload_user_votes(vote_event_ids_from_activities(activities))
  end

  def index_respond_success_js
    if activities.present?
      preload_user_votes(vote_event_ids_from_activities(activities))
      render
    else
      respond_with_204(nil, :json)
    end
  end

  def index_respond_success_serializer(format)
    return super if index_response_association.present?
    respond_with_204(nil, :json)
  end

  def relevant_only
    params[:complete] != 'true'
  end

  def resource_by_id
    return nil if feed_resource.blank?
    @resource_by_id ||=
      Feed.new(
        parent: feed_resource,
        relevant_only: relevant_only,
        root_id: tree_root_id
      )
  end
end

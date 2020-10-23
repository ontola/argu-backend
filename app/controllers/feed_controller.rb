# frozen_string_literal: true

class FeedController < AuthorizedController
  include VotesHelper
  skip_before_action :check_if_registered, only: %i[index]

  private

  def activities
    @activities ||=
      policy_scope(authenticated_resource.activities)
        .where('activities.created_at < ?', from_time)
        .order('activities.created_at DESC')
        .limit(10)
  end

  def authorize_action
    authorize feed_resource!, :feed?
  end

  def collection_view_includes(_member_includes = {})
    {member_sequence: {}}
  end

  def feed_resource
    parent_resource || tree_root
  end

  def feed_resource!
    feed_resource || raise(ActiveRecord::RecordNotFound)
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
    requested_resource.activity_collection(collection_options)
  end

  def index_success_serializer
    return respond_with_collection(active_response_options) if index_collection_or_view.present?

    head 204
  end
  alias index_success_rdf index_success_serializer
  alias index_success_json_api index_success_serializer

  def relevant_only
    params[:complete] != 'true'
  end

  def requested_resource
    return nil if feed_resource.blank?

    @requested_resource ||=
      Feed.new(
        parent: feed_resource,
        relevant_only: relevant_only,
        root_id: tree_root_id
      )
  end
end

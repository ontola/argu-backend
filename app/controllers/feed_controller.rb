# frozen_string_literal: true

class FeedController < AuthorizedController
  include VotesHelper
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: %i[index]

  alias resource_by_id parent_resource
  helper_method :complete_feed_param

  def index
    index_handler_success(nil)
  end

  private

  def authorize_action
    authorize authenticated_resource, :feed?
  end

  def authenticated_edge
    @resource_edge ||= authenticated_resource!&.edge
  end

  def authenticated_resource!
    @resource ||= parent_resource
  end

  def authenticated_tree
    @_tree ||= authenticated_edge&.self_and_ancestors
  end

  def collect_banners; end

  def complete_feed_param
    params[:complete] == 'true' && policy(authenticated_resource).log?
  end

  def feed
    Activity.feed_for_edge(
      authenticated_edge,
      !complete_feed_param
    )
  end

  def from_time
    return Time.current if params[:from_time].blank?
    begin
      Time.parse(params[:from_time]).utc.to_s
    rescue ArgumentError
      Time.current
    end
  end

  def index_response_association
    @activities ||=
      policy_scope(feed)
        .where('activities.created_at < ?', from_time)
        .order('activities.created_at DESC')
        .limit(10)
  end

  def include_index
    %w[recipient owner]
  end

  def index_respond_success_html
    preload_user_votes(vote_event_ids_from_activities(index_response_association))
  end

  def index_respond_success_js
    if index_response_association.present?
      preload_user_votes(vote_event_ids_from_activities(index_response_association))
      render
    else
      respond_with_204(nil, :json)
    end
  end

  def index_respond_success_json
    if index_response_association.present?
      render json: index_response_association, include: include_index
    else
      respond_with_204(nil, :json)
    end
  end

  def index_respond_success_serializer(format)
    return super if index_response_association.present?
    respond_with_204(nil, :json)
  end
end

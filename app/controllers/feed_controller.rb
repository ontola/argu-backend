# frozen_string_literal: true

class FeedController < AuthorizedController
  include VotesHelper
  include NestedResourceHelper
  alias resource_by_id parent_resource
  helper_method :complete_feed_param

  def show
    show_handler_success(nil)
  end

  private

  def activities
    @activities ||=
      policy_scope(feed)
        .where('activities.created_at < ?', from_time)
        .order('activities.created_at DESC')
        .limit(10)
  end

  def authorize_action
    authorize authenticated_resource, :feed?
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
    return DateTime.current if params[:from_time].blank?
    begin
      DateTime.parse(params[:from_time]).utc.to_s
    rescue ArgumentError
      DateTime.current
    end
  end

  def include_show
    %w[recipient owner]
  end

  def show_respond_success_html(_resource)
    preload_user_votes(vote_event_ids_from_activities(activities))
  end

  def show_respond_success_js(_resource)
    if activities.present?
      preload_user_votes(vote_event_ids_from_activities(activities))
      render
    else
      respond_with_204(nil, :json)
    end
  end

  def show_respond_success_json(_resource)
    if activities.present?
      render json: activities, include: %w[recipient owner]
    else
      respond_with_204(nil, :json)
    end
  end

  def show_respond_success_serializer(_resource, format)
    if activities.present?
      render format => activities, include: %w[recipient owner]
    else
      respond_with_204(nil, :json)
    end
  end
end

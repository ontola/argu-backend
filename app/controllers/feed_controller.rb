# frozen_string_literal: true
class FeedController < AuthorizedController
  include NestedResourceHelper, VotesHelper
  alias resource_by_id parent_resource
  helper_method :complete_feed_param

  def show
    @activities = policy_scope(feed)
                    .where('activities.created_at < ?', from_time)
                    .order('activities.created_at DESC')
                    .limit(10)
    respond_to do |format|
      format.html do
        preload_user_votes(vote_event_ids_from_activities(@activities))
      end
      format.js do
        if @activities.present?
          preload_user_votes(vote_event_ids_from_activities(@activities))
          render
        else
          respond_with_204(nil, :json)
        end
      end
      format.json do
        if @activities.present?
          render json: @activities, include: %w(recipient owner)
        else
          respond_with_204(nil, :json)
        end
      end
    end
  end

  private

  def authorize_action
    authorize authenticated_resource, :feed?
  end

  def authenticated_resource!
    @resource ||= parent_resource
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
    return DateTime.current unless params[:from_time].present?
    begin
      DateTime.parse(params[:from_time]).utc.to_s
    rescue ArgumentError
      DateTime.current
    end
  end

  def parent_resource(opts = params)
    super if parent_resource_key(opts).present?
  end
end

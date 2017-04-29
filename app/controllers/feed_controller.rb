# frozen_string_literal: true
class FeedController < AuthorizedController
  include NestedResourceHelper, VotesHelper
  alias resource_by_id get_parent_resource

  def show
    @activities = policy_scope(feed)
                    .where('activities.created_at < ?', from_time)
                    .order('activities.created_at DESC')
                    .limit(10)
    respond_to do |format|
      format.html do
        preload_user_votes(@activities.where(trackable_type: 'Motion').pluck(:trackable_id))
      end
      format.js do
        if @activities.present?
          preload_user_votes(@activities.where(trackable_type: 'Motion').pluck(:trackable_id))
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
    @resource ||= get_parent_resource
  end

  def collect_banners; end

  def feed
    Activity.feed_for_edge(authenticated_resource.edge)
  end

  def from_time
    return DateTime.current unless params[:from_time].present?
    begin
      DateTime.parse(params[:from_time]).utc.to_s
    rescue ArgumentError
      DateTime.current
    end
  end

  def get_parent_resource(opts = params)
    super if parent_resource_key(opts).present?
  end
end

# frozen_string_literal: true

# @note: Common create ready
class NotificationsController < AuthorizedController # rubocop:disable Metrics/ClassLength
  include NotificationsHelper

  skip_before_action :authorize_action, only: :index

  after_action :update_viewed_time

  def show
    respond_to do |format|
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { render type => authenticated_resource, include: :operation }
      end
      format.all { redirect_to authenticated_resource.activity.trackable.iri(only_path: true).to_s }
    end
  end

  def read
    if policy_scope(Notification)
         .where(read_at: nil, permanent: false)
         .update_all(read_at: Time.current)
      @notifications = get_notifications
      @unread = unread_notification_count
      render 'notifications/index'
    else
      head 400
    end
  end

  private

  def authorize_action
    return super unless action_name == 'read'
    authorize Notification, :read?
  end

  def fetch_more
    begin
      from_time = Time.parse(params[:from_time]).utc.to_s
    rescue ArgumentError
      from_time = nil
    end
    @from_time = from_time
    @notifications = policy_scope(Notification)
                       .order(created_at: :desc)
                       .since(from_time)
                       .page params[:page]
    @unread = unread_notification_count
  rescue ArgumentError
    head 400
  end

  def get_notifications(since = nil)
    policy_scope(Notification)
      .includes(activity: :trackable)
      .order(permanent: :desc, created_at: :desc)
      .where(since ? ['created_at > ?', since] : nil)
      .page params[:page]
  end

  def show_includes
    [operation: :target]
  end

  def index_success_html
    head 204
  end

  def index_success_json
    if current_user.guest?
      head 204
    elsif params[:from_time].present?
      fetch_more
    else
      refresh
    end
  end

  def index_collection
    @collection ||= ::Collection.new(
      association_class: Notification,
      default_type: :infinite,
      user_context: user_context,
      parent: nil
    )
  end

  def index_meta
    m = []
    m <<
      if index_collection.is_a?(CollectionView)
        [
          ::RDF::URI(index_collection.collection.iri),
          NS::AS[:page],
          ::RDF::URI(index_collection.iri)
        ]
      else
        [
          ::RDF::URI(index_collection.iri),
          NS::ARGU[:unreadCount],
          unread_notification_count
        ]
      end
    m
  end

  def new_available?(since)
    return true if since.blank?
    policy_scope(Notification).where('created_at > ?', since).count.positive?
  end

  def permit_params
    params.require(:notification).permit(*policy(@notification || Notification).permitted_attributes)
  end

  def refresh
    since = Time.parse(last_notification).utc.to_s(:db) if last_notification
    @notifications = get_notifications(since) if new_available?(since)
    if @notifications.present?
      @unread = unread_notification_count
      render
    else
      head 204
    end
  rescue ArgumentError
    head 400
  end

  def update_execute
    n = authenticated_resource
    read_before = n.read_at.present?
    read_before || n.permanent? || n.update(read_at: Time.current)
  end

  def update_meta
    index_meta + super
  end

  def update_success_serializer
    respond_with_resource(resource: authenticated_resource, include: show_includes, meta: index_meta)
  end

  def update_respond_success_html(_resource)
    @notifications = get_notifications
    @unread = unread_notification_count
    render 'index'
  end

  def update_failure
    head 400
  end

  def update_viewed_time
    current_user.update(notifications_viewed_at: Time.current) unless current_user.guest?
  end

  def last_notification
    date = params[:lastNotification].presence || request.headers[:lastNotification].presence
    date if date != 'null' && date != 'undefined'
  end
end

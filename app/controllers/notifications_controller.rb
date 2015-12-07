class NotificationsController < ApplicationController
  after_action :update_viewed_time

  def index
    # This must be performed to prevent pundit errors
    policy_scope(Notification)
    if current_user.present?
      if params[:from_time].present?
        fetch_more
      else
        refresh
      end
    else
      policy_scope(Notification)
      head 204
    end

    respond_to do |format|
      format.json { render }
    end
  end

  def show
    notification = Notification.find params[:id]
    authorize notification, :show?

    redirect_to url_for(notification.activity.trackable)
  end

  def create
    authorize Notification, :create?
    @notification = Notification.new permit_params

    respond_to do |format|
      if @notification.save
        format.json { head 201 }
      else
        format.json { render json: @notification.errors }
      end
    end
  end

  def read
    authorize Notification, :read?

    if policy_scope(Notification).where(read_at: nil).update_all read_at: Time.current

      @notifications = get_notifications
      render 'notifications/index'
    else
      head 400
    end
  end

  def update
    notification = Notification.includes(activity: :trackable).find(params[:id])
    authorize notification, :update?

    if notification.read_at.present? || notification.update(read_at: Time.current)
      @notifications = get_notifications
      @unread = get_unread
      render 'index'
    else
      head 400
    end
  end

  private
  def fetch_more
    begin
      begin
        from_time = DateTime.parse(params[:from_time]).utc.to_s
      rescue ArgumentError
        from_time = nil
      end
      @from_time = from_time
      @notifications = policy_scope(Notification).since(from_time).page params[:page]
      @unread = get_unread
    rescue ArgumentError
      head 400
    end
  end

  def get_notifications(since=nil)
    policy_scope(Notification)
        .includes(activity: :trackable)
        .order(created_at: :desc)
        .where(since ? ['created_at > ?', since] : nil)
        .page params[:page]
  end

  def get_unread
    policy_scope(Notification)
        .where('read_at is NULL')
        .order(created_at: :desc)
        .count
  end

  def permit_params
    params.require(:notification).permit(*policy(@notification || Notification).permitted_attributes)
  end

  def refresh
    begin
      since = DateTime.parse(last_notification).utc.to_s(:db) if last_notification
      new_available = true
      if since.present?
        new_available = policy_scope(Notification)
                            .order(created_at: :desc)
                            .where('created_at > ?', since)
                            .count > 0
      end
      @notifications = get_notifications(since) if new_available
      if @notifications.present?
        @unread = get_unread
        render
      else
        head 204
      end
    rescue ArgumentError
      head 400
    end
  end

  def update_viewed_time
    current_user.update(notifications_viewed_at: Time.current) if current_user.present?
  end

  def last_notification
    date = params[:lastNotification].presence || request.headers[:lastNotification].presence
    date if date != 'null' && date != 'undefined'
  end
end

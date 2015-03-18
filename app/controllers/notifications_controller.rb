class NotificationsController < ApplicationController

  def index
    if current_user.present?
      since = DateTime.parse(request.headers[:lastNotification]).to_s(:db) if request.headers[:lastNotification]
      new_available = true
      if since.present?
        new_available = policy_scope(Notification).order(created_at: :desc).where('created_at > ?', since).count > 0
      end
      @notifications = get_notifications(since) if new_available
    else
      # This must be performed to prevent pundit errors
      policy_scope(Notification)
    end
    if @notifications.present?
      @unread = get_unread
      render
    else
      head 204
    end
  end

  def update
    notification = Notification.includes(activity: :trackable).find(params[:id])
    authorize notification, :update?

    if notification.read_at.present? || notification.update(read_at: Time.now)
      @notifications = get_notifications
      @unread = get_unread
      render 'index'
    else
      head 400
    end
  end

private

  def get_notifications(since=nil)
    policy_scope(Notification).includes(activity: :trackable).order(created_at: :desc).where(since ? ['created_at > ?', since] : nil).page params[:page]
  end

  def get_unread
    policy_scope(Notification).where('read_at is NULL').order(created_at: :desc).count
  end
end
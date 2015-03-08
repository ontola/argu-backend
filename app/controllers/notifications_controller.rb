class NotificationsController < ApplicationController

  def index
    @notifications = get_notifications
    @unread = get_unread
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

  def get_notifications
    policy_scope(current_user.profile.notifications).includes(activity: :trackable).order(created_at: :desc).page params[:page]
  end

  def get_unread
    policy_scope(Notification).where('read_at is NULL').order(created_at: :desc).count
  end
end
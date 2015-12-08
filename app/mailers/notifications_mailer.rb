
class NotificationsMailer < ApplicationMailer
  include MailerHelper

  def notifications_email(user, notifications)
    @user = user
    @notifications = notifications

    if @notifications.length > 1
      mail to: @user.email,
           subject: t('mailer.notifications_mailer.subject')
    else
      @notification = @notifications.first
      @item = @notification.activity.trackable
      @parent = @notification.activity.recipient
      mail to: @user.email,
           subject: notification_subject(@notification),
           template_name: 'single_item_email'
    end
  end


end

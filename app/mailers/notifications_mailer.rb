# frozen_string_literal: true

class NotificationsMailer < ApplicationMailer
  include MailerHelper
  add_template_helper(ApplicationHelper)
  add_template_helper(DecisionsHelper)
  add_template_helper(BlogPostsHelper)

  def notifications_email(user, notifications)
    @user = user
    @notifications = notifications

    I18n.with_locale(@user.language) do
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

  def confirmation_reminder(notification)
    @user = notification.user
    I18n.with_locale(@user.language) do
      mail to: @user.email,
           subject: t('mailer.notifications_mailer.confirmation_reminder.subject')
    end
  end
end

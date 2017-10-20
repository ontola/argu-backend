# frozen_string_literal: true

class NotificationsMailer < ApplicationMailer
  def confirmation_reminder(notification)
    @user = notification.user
    I18n.with_locale(@user.language) do
      mail to: @user.email,
           subject: t('mailer.notifications_mailer.confirmation_reminder.subject')
    end
  end
end

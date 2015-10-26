
class NotificationsMailer < ApplicationMailer

  def notifications_email(user, notifications)
    @user = user
    @notifications = notifications

    if @notifications.length > 1
      mail to: @user.email,
           subject: t('mailer.notifications_mailer.subject')
    else
      @notification = @notifications.first
      @item = @notification.activity.recipient
      mail to: @user.email,
           subject: '_new item for ' + @item.display_name,
           template_name: "user_created_#{@item.model_name.singular}"
    end
  end
end

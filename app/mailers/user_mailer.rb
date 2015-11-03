
class UserMailer < ApplicationMailer
  def user_password_changed(user)
    @user = user
    mail to: @user.email,
         subject: t('mailer.user_mailer.password.changed.subject')
  end
end

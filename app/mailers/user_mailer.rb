
# frozen_string_literal: true
class UserMailer < ApplicationMailer
  def user_password_changed(user)
    @user = user
    mail to: @user.email,
         subject: t('devise.registrations.password_confirmation.header')
  end

  def set_password_instructions(user, token)
    @user = user
    @token = token
    mail to: @user.email,
         subject: t('devise.mailer.set_password_instructions.subject')
  end
end

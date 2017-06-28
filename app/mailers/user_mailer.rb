
# frozen_string_literal: true
class UserMailer < ApplicationMailer
  def user_password_changed(user)
    @user = user
    mail to: @user.email,
         subject: t('devise.registrations.password_confirmation.header')
  end
end

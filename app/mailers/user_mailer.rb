
class UserMailer < ApplicationMailer
  def user_password_changed(user)
    @user = user
    mail to: @user.email,
         subject: 'Argu wachtwoord gewijzigd'
  end
end

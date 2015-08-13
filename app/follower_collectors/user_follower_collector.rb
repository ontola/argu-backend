class UserFollowerCollector < ActionMailer::Base
  default from: 'info@argu.co'

  def password_changed_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Argu wachtwoord gewijzigd')
  end
end

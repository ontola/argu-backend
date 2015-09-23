
class UserMailer < ApplicationMailer

  def user_commented(item, recipients, opts = {})
    @comment = item
    mail to: recipients,
         subject: t('mailer.user_mailer.user_commented.subject', title: @comment.commentable.display_name)
  end

  def user_added_argument(item, recipients, opts = {})
    @argument = item
    mail to: recipients
  end

end

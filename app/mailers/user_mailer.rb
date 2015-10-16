
class UserMailer < ApplicationMailer

  def user_created_argument(item, recipients, opts = {})
    @argument = item
    mail to: recipients
  end

  def user_created_comment(item, recipients, opts = {})
    @comment = item
    @parent = opts[:parent]
    mail to: recipients,
         subject: t('mailer.user_mailer.user_created_comment.subject', title: type_for(@parent).downcase, parent: @parent.display_name, poster: @comment.creator.display_name )
  end

  def user_created_motion(item, recipients, opts = {})
    @motion = item
    mail to: recipients,
         subject: t('mailer.user_mailer.user_created_motion.subject', title: @motion.forum.display_name)
  end

  def user_created_question(item, recipients, opts = {})
    @question = item
    mail to: recipients,
         subject: t('mailer.user_mailer.user_created_question.subject', title: @question.forum.display_name)
  end

  def user_password_changed(user)
    @user = user
    mail to: @user.email,
         subject: 'Argu wachtwoord gewijzigd'
  end
end

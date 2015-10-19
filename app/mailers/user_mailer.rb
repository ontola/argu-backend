
class UserMailer < ApplicationMailer

  def user_created_argument(item, recipients, opts = {})
    @argument = item
    @parent = opts[:parent]
    mail to: recipients,
         subject: t("mailer.user_mailer.user_created_argument.subject_#{@argument.pro? ? 'pro' : 'con'}", parent_type: type_for(@parent).downcase, parent_title: @parent.display_name, poster: @argument.creator.display_name, type: type_for(@argument).downcase)
  end

  def user_created_comment(item, recipients, opts = {})
    @comment = item
    @parent = opts[:parent]
    mail to: recipients,
         subject: t('mailer.user_mailer.user_created_comment.subject', parent_type: type_for(@parent).downcase, parent_title: @parent.display_name, poster: @comment.creator.display_name )
  end

  def user_created_motion(item, recipients, opts = {})
    @motion = item
    @parent = opts[:parent]
    mail to: recipients,
         subject: t('mailer.user_mailer.user_created_motion.subject', title: @motion.display_name, type: type_for(@motion).downcase, poster: @motion.creator.display_name )
  end

  def user_created_question(item, recipients, opts = {})
    @question = item
    @parent = opts[:parent]
    mail to: recipients,
         subject: t('mailer.user_mailer.user_created_question.subject', title: @question.display_name, type: type_for(@question).downcase, poster: @question.creator.display_name )
  end

  def user_password_changed(user)
    @user = user
    mail to: @user.email,
         subject: t('mailer.user_mailer.password.changed.subject')
  end
end

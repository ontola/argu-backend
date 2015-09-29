class MailerListener

  def create_argument_successful(argument)
    recipients = follower_emails_for(argument, argument.motion)
    # TODO: single out the creator and send a different mail
    if recipients.present?
      UserMailer
          .user_created_argument(argument, recipients)
          .deliver_now
    end
  end

  def create_comment_successful(comment)
    recipients = follower_emails_for(comment, comment.subscribable)
    # TODO: single out the creator and send a different mail
    if recipients.present?
      UserMailer
          .user_created_comment(comment, recipients)
          .deliver_now
    end
  end

  def create_motion_successful(motion)
    parent = motion.questions.length == 1 ? motion.questions.first : motion.forum
    recipients = follower_emails_for(motion, parent)
    # TODO: single out the creator and send a different mail
    if recipients.present?
      UserMailer
          .user_created_motion(motion, recipients)
          .deliver_now
    end
  end

  def create_question_successful(question)
    recipients = follower_emails_for(question, question.forum)
    # TODO: single out the creator and send a different mail
    if recipients.present?
      UserMailer
          .user_created_question(question, recipients)
          .deliver_now
    end
  end

  def follower_emails_for(resource, in_response_to)
    in_response_to
        .subscribers
        .where.not(id: resource.creator.id)
        .where.not(confirmed_at: nil)
        .where(follows_email: User.follows_emails[:direct_follows_email])
        .pluck(:email)
  end
end

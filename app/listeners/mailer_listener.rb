class MailerListener

  def create_comment_successful(comment)
    recipients = follower_emails_for(comment, comment.commentable)
    # TODO: single out the creator and send a different mail
    if recipients.present?
      UserMailer
          .user_commented(comment, recipients)
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
        .pluck(:email)
  end
end

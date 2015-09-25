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

  def follower_emails_for(resource, in_response_to)
    in_response_to
        .subscribers
        .where.not(id: resource.creator.id)
        .where.not(confirmed_at: nil)
        .pluck(:email)
  end
end

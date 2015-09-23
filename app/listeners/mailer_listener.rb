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
        .followers
        .map { |u| u.email if follower_inclusion_clause(u, resource) }
        .compact
  end

  def follower_inclusion_clause(user, resource)
    user != resource.creator && user.confirmed?
  end
end

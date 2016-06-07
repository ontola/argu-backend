class MailerListener
  def create_argument_successful(argument)
    send_followers_mail argument, follower_emails_for(argument, argument.motion)
  end

  def create_comment_successful(comment)
    send_followers_mail comment, follower_emails_for(comment, comment.subscribable)
  end

  def create_motion_successful(motion)
    parent = motion.questions.length == 1 ? motion.questions.first : motion.forum
    send_followers_mail motion, follower_emails_for(motion, parent)
  end

  def create_question_successful(question)
    send_followers_mail question, follower_emails_for(question, question.forum)
  end

  private

  def send_followers_mail(resource, recipients)
    # TODO: single out the creator and send a different mail
    if recipients.present?
      UserMailer
          .public_send("user_created_#{resource.type.to_s}",
                       question,
                       recipients,
                       parent: parent_for_resource(resource))
          .deliver_now
    end
  end

  def follower_emails_for(resource, in_response_to)
    in_response_to
        .subscribers
        .where.not(id: resource.creator.id)
        .where.not(confirmed_at: nil)
        .where(reactions_email: User.reactions_emails[:direct_reactions_email])
        .pluck(:email)
  end

  def parent_for_resource(resource)
    if resource.activities.length > 0
      notify_bugnsag(resource) if resource.activities.length != 1
      resource.activities.first.recipient
    elsif resource.activities.length == 0
      notify_bugnsag(resource)
      resource.try :forum
    end
  end

  def notify_bugnsag(r)
    e = StandardError.new "Resource #{r.identifier} has wrong number of activities"
    ::Bugsnag.notify(e, severity: 'error')
  end
end

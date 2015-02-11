class CommentMailer < MailerBase

  def mail_creators
    recipients = Hash.new

    # Mail Motion owner if not the creator
    recipients.merge!(profile_to_recipient_option(@commentable.creator)) if different_creator @comment, @commentable
    #TODO: make it mail the question creator
    # Mail the forum owner if not the creator and we haven't just added the forum creator
    if @activity.recipient.class != Forum
      recipients.merge! profile_to_recipient_option(@commentable.forum.creator) if different_creator @comment, @commentable.forum
    end
  end

end
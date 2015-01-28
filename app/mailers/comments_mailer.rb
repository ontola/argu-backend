class CommentsMailer
  include MailerHelper

  def initialize(activity)
    @activity = activity
    @comment = activity.trackable
    @commentable = activity.recipient
  end

  def collect_recipients
    recipients = Hash.new
    # My items
    recipients.merge!(mail_creators)
  end

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

  def mail_forum_members

  end

end
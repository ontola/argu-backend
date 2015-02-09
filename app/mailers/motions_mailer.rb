class MotionsMailer
  include MailerHelper

  def initialize(activity)
    @activity = activity
    @motion = activity.trackable
  end

  def collect_recipients
    recipients = Hash.new
    # My items
    recipients.merge!(mail_creators)
  end

  def mail_creators
    recipients = Hash.new

    # Mail forum owner or Question owner if not the creator
    recipients.merge!(profile_to_recipient_option(@activity.recipient.creator)) if different_creator @motion, @activity.recipient
    # Mail the forum owner if not the creator and we haven't just added the forum creator
    if @activity.recipient.class != Forum
      recipients.merge! profile_to_recipient_option(@activity.recipient.forum.creator) if different_creator @motion, @activity.recipient.forum
    end
  end

  def mail_forum_members

  end

end
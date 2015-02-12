class MailerBase
  include MailerHelper

  def initialize(activity)
    @activity = activity
    @thing = activity.trackable
  end



end
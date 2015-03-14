class Argu::NotificationWorker
  include Sidekiq::Worker
  include MailerHelper

  def perform(activity_id)
    @activity = Activity.find_by_id activity_id

    set_locale

    # TODO: split by locale
    if @activity.present?
      recipients = recipients_for_activity(@activity)

      build_notifications recipients, @activity

      #mailer = Argu::ActivityMailer.new(@activity)
      #mailer.send!
    end
  end

  def build_notifications(recipients, activity)
    if recipients.present?
      inserts = []
      time = Time.now.to_s(:db)
      recipients.each do |r|
        inserts.push "(#{r.profile.id}, #{activity.id}, '#{time}', '#{time}')"
      end
      sql = "INSERT INTO notifications (profile_id, activity_id, created_at, updated_at) VALUES #{inserts.join(', ')}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end

  def recipients_for_activity(a)
    items = a.key.split('.')
    mailer = "#{items.first}_mailer".classify.safe_constantize
    if mailer
      mailer.new(a).send(items.last)
    else
      []
    end
  end

end
class Argu::NotificationWorker
  require 'sidekiq/logging/json'
  Sidekiq.logger.formatter = Sidekiq::Logging::Json::Logger.new
  include Sidekiq::Worker

  def perform(activity_id)
    @activity = Activity.find_by_id activity_id

    set_locale

    # TODO: split by locale
    if @activity.present?
      recipients = @activity.followers
      build_notifications recipients, @activity
    end
  end

  def build_notifications(recipients, activity)
    if recipients.present?
      inserts = []
      time = Time.now.iso8601(6)
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

end

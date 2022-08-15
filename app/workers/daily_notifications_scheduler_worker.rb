# frozen_string_literal: true

class DailyNotificationsSchedulerWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker

  def perform
    ActsAsTenant.without_tenant do
      send_activity_notifications(User.reactions_emails[:daily_reactions_email])
    end
  end
end

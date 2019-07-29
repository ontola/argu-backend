# frozen_string_literal: true

class WeeklyNotificationsSchedulerWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { weekly }

  def perform
    ActsAsTenant.without_tenant do
      Apartment::Tenant.each do
        send_activity_notifications(User.reactions_emails[:weekly_reactions_email])
      end
    end
  end
end

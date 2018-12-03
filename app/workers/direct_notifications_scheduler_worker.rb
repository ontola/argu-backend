# frozen_string_literal: true

class DirectNotificationsSchedulerWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    send_activity_notifications(User.reactions_emails[:direct_reactions_email])

    send_individual_notifications
  end

  private

  # Send mails for Notifications with a send_mail_after value later than the current date
  # if the NotificationsMailer has a method for it.
  def send_individual_notifications # rubocop:disable Metrics/AbcSize
    t_notifications = Notification.arel_table
    Notification
      .where(t_notifications[:read_at].eq(nil))
      .where(t_notifications[:send_mail_after].lt(Time.current))
      .each do |notification|
      notification.update!(send_mail_after: nil)
      Argu::API
        .service_api
        .create_email(
          notification.notification_type,
          notification.user,
          token: notification.user.primary_email_record.confirmation_token
        )
    end
  end
end

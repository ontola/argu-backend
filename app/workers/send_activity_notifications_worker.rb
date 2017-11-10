# frozen_string_literal: true

require 'argu/api'

class SendActivityNotificationsWorker
  include Sidekiq::Worker

  COOLDOWN_PERIOD = 4.minutes

  def perform(user_id, delivery_type)
    @user = User.find(user_id)

    unless delivery_type.present? && User.reactions_emails[@user.reactions_email] == delivery_type
      logger.warn "Not sending notifications to mismatched delivery type #{delivery_type} for user #{@user.id}"
      return
    end

    ActiveRecord::Base.transaction do
      begin
        collect_activity_notifications
        if @notifications.length.zero?
          logger.warn 'No notifications to send'
        else
          logger.info "Preparing to possibly send #{@notifications.length} notifications"
          send_activity_notifications_mail if outside_cooldown_period
        end
      rescue ActiveRecord::StatementInvalid => e
        logger.error 'Queue collision occurred' if e.message.include? 'LockNotAvailable'
        Bugsnag.auto_notify(e) if Rails.env.production?
      end
    end
  end

  private

  def add_prepared_notification(result, notification)
    activity = notification.activity
    trackable_edge = activity.trackable_edge
    followable_edge = activity.new_content? ? activity.recipient_edge : trackable_edge
    return if followable_edge.nil?

    result[followable_edge.id] ||= Struct::Follow.new(
      @user.follow_for(followable_edge)&.unsubscribe_iri,
      {display_name: followable_edge.root.display_name},
      {
        id: followable_edge.owner.iri,
        display_name: followable_edge.display_name,
        pro: followable_edge.owner.try(:pro),
        type: followable_edge.owner_type
      },
      []
    )
    result[followable_edge.id].notifications << {
      action: activity.action,
      content: activity.comment || trackable_edge.content,
      id: trackable_edge.owner.iri,
      display_name: trackable_edge.display_name,
      pro: trackable_edge.owner.try(:pro),
      type: trackable_edge.owner_type,
      creator: {
        id: activity.owner.iri,
        thumbnail: activity.owner.default_profile_photo.thumbnail,
        display_name: activity.owner.display_name
      }
    }
  end

  def collect_activity_notifications
    t_notifications = Notification.arel_table
    @notifications =
      @user
        .notifications
        .for_activity
        .where(t_notifications[:read_at]
                 .eq(nil)
                 .and(t_notifications[:created_at]
                        .gt(@user.notifications_viewed_at || 1.year.ago)))
        .order(created_at: :desc)
        .lock('FOR UPDATE NOWAIT')
  end

  def outside_cooldown_period
    last_viewed = @user.reload.notifications_viewed_at
    (last_viewed.blank? || last_viewed && (last_viewed < (Time.current - COOLDOWN_PERIOD)))
  end

  def prepared_notifications
    result = {}
    @notifications
      .includes(
        activity: {
          owner: %i[default_profile_photo profileable],
          recipient_edge: :owner, trackable_edge: :owner
        }
      )
      .each { |notification| add_prepared_notification(result, notification) }
    Hash[result.map { |k, v| [k, v.to_h] }]
  end

  def send_activity_notifications_mail
    logger.info "Sending #{@notifications.length} notification(s) to #{@user.email}"
    Argu::API
      .service_api
      .create_email(
        :activity_notifications,
        @user,
        follows: prepared_notifications
      )
    @user.update_column(:notifications_viewed_at, Time.current)
  end
end

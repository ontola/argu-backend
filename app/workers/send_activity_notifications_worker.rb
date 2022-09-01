# frozen_string_literal: true

class SendActivityNotificationsWorker # rubocop:disable Metrics/ClassLength
  include Sidekiq::Worker

  COOLDOWN_PERIOD = 4.minutes

  attr_reader :user

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def perform(user_id, delivery_type)
    ActsAsTenant.without_tenant do
      @user = User.find(user_id)

      return if wrong_delivery_type?(delivery_type) || inside_cooldown_period

      ActiveRecord::Base.transaction do
        if notifications.exists?
          send_activity_notifications_mail
        else
          logger.warn 'No notifications to send'
        end
      rescue ActiveRecord::StatementInvalid => e
        logger.error 'Queue collision occurred' if e.message.include? 'LockNotAvailable'
        Bugsnag.notify(e) if Rails.env.production?
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def add_prepared_notification(result, notification)
    activity = notification.activity
    trackable = activity.trackable
    followable = activity.new_content? ? activity.recipient : trackable
    return result if followable.nil?

    result[followable.id] ||= follow_struct(followable)
    result[followable.id].notifications << prepared_notification(activity, trackable)
    result
  end

  def follow_struct(followable)
    follow_id = user.follow_for(followable)&.iri
    followable = {
      id: followable.iri,
      display_name: followable.display_name,
      pro: followable.try(:pro),
      type: followable.owner_type
    }
    notifications = []
    Struct::Follow.new(follow_id, followable, notifications)
  end

  def fresh_notifications_query
    Notification.arel_table[:read_at].eq(nil)
      .and(Notification.arel_table[:created_at].gt(user.notifications_viewed_at || 1.year.ago))
  end

  def notifications
    @notifications ||=
      user
        .notifications
        .for_activity
        .where(fresh_notifications_query)
        .order(created_at: :desc)
        .lock('FOR UPDATE NOWAIT')
  end

  def inside_cooldown_period
    last_viewed = user.notifications_viewed_at

    last_viewed.present? && last_viewed > (Time.current - COOLDOWN_PERIOD)
  end

  def joined_notifications
    notifications
      .where(root: ActsAsTenant.current_tenant)
      .includes(
        activity: [
          :recipient,
          :trackable,
          {owner: [profileable: :default_profile_photo]}
        ]
      )
  end

  def prepared_notification(activity, trackable) # rubocop:disable Metrics/MethodLength
    {
      action: activity.action,
      content: activity.comment || trackable.content,
      id: trackable.iri,
      display_name: trackable.display_name,
      pro: trackable.try(:pro),
      type: trackable.owner_type,
      creator: {
        id: activity.owner.iri,
        thumbnail: activity.owner.profileable.default_profile_photo.thumbnail,
        display_name: activity.owner.display_name
      }
    }
  end

  def prepared_notifications
    joined_notifications.reduce({}) do |result, notification|
      add_prepared_notification(result, notification)
    end.transform_values(&:to_h)
  end

  def send_activity_notifications_mail
    notifications.pluck(:root_id).uniq.each do |root_id|
      ActsAsTenant.with_tenant(Page.find_by(uuid: root_id)) do
        Argu::API
          .new
          .create_email(:activity_notifications, user, follows: prepared_notifications)
      end
    end
    user.update_column(:notifications_viewed_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def wrong_delivery_type?(delivery_type)
    return false if delivery_type.present? && User.reactions_emails[user.reactions_email] == delivery_type

    logger.warn "Not sending notifications to mismatched delivery type #{delivery_type} for user #{user.id}"
    true
  end
end

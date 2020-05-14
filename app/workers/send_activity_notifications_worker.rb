# frozen_string_literal: true

class SendActivityNotificationsWorker
  include Sidekiq::Worker

  COOLDOWN_PERIOD = 4.minutes

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def perform(user_id, delivery_type)
    ActsAsTenant.without_tenant do
      @user = User.find(user_id)

      return if wrong_delivery_type?(delivery_type)

      ActiveRecord::Base.transaction do
        collect_activity_notifications
        if @notifications.length.zero?
          logger.warn 'No notifications to send'
        else
          logger.info "Preparing to possibly send #{@notifications.length} notifications"
          send_activity_notifications_mail if outside_cooldown_period
        end
      rescue ActiveRecord::StatementInvalid => e
        logger.error 'Queue collision occurred' if e.message.include? 'LockNotAvailable'
        Bugsnag.notify(e) if Rails.env.production?
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def add_prepared_notification(result, notification) # rubocop:disable Metrics/AbcSize
    activity = notification.activity
    trackable = activity.trackable
    followable = activity.new_content? ? activity.recipient : trackable
    return if followable.nil?

    result[followable.id] ||= Struct::Follow.new(
      ActsAsTenant.with_tenant(followable.root) { @user.follow_for(followable)&.iri },
      {display_name: followable.root.display_name},
      {
        id: followable.iri,
        display_name: followable.display_name,
        pro: followable.try(:pro),
        type: followable.owner_type
      },
      []
    )
    result[followable.id].notifications << {
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
        activity: [
          :recipient,
          :trackable,
          owner: [profileable: :default_profile_photo]
        ]
      )
      .each { |notification| add_prepared_notification(result, notification) }
    result.transform_values(&:to_h)
  end

  def send_activity_notifications_mail
    logger.info "Sending #{@notifications.length} notification(s) to #{@user.email}"
    notifications = prepared_notifications
    ActsAsTenant.with_tenant(Page.find_by(uuid: @notifications.uniq.pluck(:root_id).first)) do
      Argu::API
        .service_api
        .create_email(:activity_notifications, @user, follows: notifications)
    end
    @user.update_column(:notifications_viewed_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def wrong_delivery_type?(delivery_type)
    return false if delivery_type.present? && User.reactions_emails[@user.reactions_email] == delivery_type

    logger.warn "Not sending notifications to mismatched delivery type #{delivery_type} for user #{@user.id}"
    true
  end
end

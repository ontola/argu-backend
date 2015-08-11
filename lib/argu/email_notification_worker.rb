require 'render_anywhere'

# Mailer class for mailing users when an activity is created
class Argu::EmailNotificationWorker
  include Sidekiq::Worker
  include RenderAnywhere

  def perform(activity_id, delayed_recipients = [])
    @activity = Activity.find_by_id activity_id

    if @activity.present?
      redis = Redis.new
      if delayed_recipients.any?
        @recipients = User.where(id: delayed_recipients)
                          .select { |u| may_send(u, @activity, redis) }
                          .map(&:user_to_recipient_option)
                          .reduce({}, :merge)
      else
        @recipients = @activity
                          .followers
                          .select { |u| may_send(u, @activity, redis) }
                          .map(&:user_to_recipient_option)
                          .reduce({}, :merge)

        # Only select users where their online status was uncertain at the time of the incidence
        delayed_recipients = @activity
                               .followers
                               .select { |u| u.active_since?(@activity.created_at - 30.seconds, redis) }
                               .map(&:id)
        if delayed_recipients.any?
          EmailNotificationWorker.perform_in(5.minutes, activity_id, delayed_recipients)
        end
      end
      send!
    end
  end

  def may_send(u, activity, redis)
    u.class == User && u.direct_follows_email? &&
        !u.active_since?(activity.created_at - 30.seconds, redis) &&
        (u.last_email_sent_at(redis).to_i < [u.active_at(redis).to_i, 1.hour.ago.to_i].min)
  end

  # Renders the accompanying view for the activity
  def render_mail
    @rendered_html = render 'mailer/direct_mail', layout: false, locals: { activity: @activity }
  end

  # Sends the actual messages
  def send!
    begin
      if @recipients.length > 0
        unless Rails.env.development?
          response = RestClient.post "https://api:key-#{Rails.application.secrets.mailgun_api_token}"\
      "@api.mailgun.net/v2/sandbox45cac23aba3c496ab26b566ddae1bd5b.mailgun.org/messages",
                          from: Rails.application.secrets.mailgun_sender,
                          to: @recipients.keys.join(','),
                          'recipient-variables' => @recipients.to_json,
                          subject: subject,
                          text: 'text',
                          html: render_mail.to_str # This MUST say .to_str otherwise it will crash on SafeBuffer
          if response.code == 200
            redis = Redis.new
            current_time = DateTime.now
            redis.pipelined do
              @recipients.each do |r_o|
                redis.set("user:#{r_o[r_o.keys.first]['id']}:email.sent.at", current_time)
              end
            end
          end
        end
      else
        logger.info 'No recepients'
      end
    rescue => e
      logger.error e
      raise e
    end
  end

  # Returns the subject for the mail
  def subject
    s = I18n.t('mailer.subject', type: I18n.t("#{@activity.trackable.class_name}.type_new"),
           item: @activity.recipient.display_name)
    s[0] = s[0].capitalize
    s
  end

end

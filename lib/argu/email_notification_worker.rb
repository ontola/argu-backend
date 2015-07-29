require 'render_anywhere'

# Mailer class for mailing users when an activity is created
class Argu::EmailNotificationWorker
  include Sidekiq::Worker
  include RenderAnywhere

  def perform(activity_id)
    @activity = Activity.find_by_id activity_id

    if @activity.present?
      @recipients = @activity
                        .followers
                        .select { |u| u.class == User && u.direct_follows_email? }
                        .map(&:user_to_recipient_option)
                        .reduce({}, :merge)
      send!
    end
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
          RestClient.post "https://api:key-#{Rails.application.secrets.mailgun_api_token}"\
      "@api.mailgun.net/v2/sandbox45cac23aba3c496ab26b566ddae1bd5b.mailgun.org/messages",
                          from: Rails.application.secrets.mailgun_sender,
                          to: @recipients.keys.join(','),
                          'recipient-variables' => @recipients.to_json,
                          subject: subject,
                          text: 'text',
                          html: render_mail.to_str # This MUST say .to_str otherwise it will crash on SafeBuffer
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

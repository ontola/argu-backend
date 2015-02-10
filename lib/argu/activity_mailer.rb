# Mailer class for mailing users when an activity is created
class Argu::ActivityMailer

  def initialize(a)
    @activity = a
  end

  def collect_recipients
    recipients = Set.new
    recipients.merge @activity.collect_recipients

  end

  # Renders the accompanying view for the activity
  def render
    Slim::Template.new("app/views/mailer/direct/#{@activity.trackable.class_name}.html.slim").render()
  end

  # Sends the actual messages
  def send!
    begin
      RestClient.post "https://api:key-#{Rails.application.secrets.mailgun_api_token}"\
  "@api.mailgun.net/v2/sandbox45cac23aba3c496ab26b566ddae1bd5b.mailgun.org/messages",
                      from: Rails.application.secrets.mailgun_sender,
                      to: recipient_variables.keys.join(','),
                      'recipient-variables' => collect_recipients.to_json,
                      subject: subject,
                      text: "",
                      html: render
      logger.info "Sent a mail to: #{recipient_variables.to_s}"
    rescue => e
      logger.error e.response
      raise e
    end
  end

  # Returns the subject for the mail
  def subject
    I18n.t('mailer.subject', type: I18n.t("#{@activity.trackable.class_name}.type"),
           item: I18n.t("#{@activity.recipient.class_name}.type"))
  end

end
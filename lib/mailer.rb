require 'rest_client'
require 'multimap'

class Mailer
  include Sidekiq::Worker

  def send_message(recipient_variables, subject, body)
    begin
      RestClient.post "https://api:key-#{Rails.application.secrets.mailgun_api_token}"\
  "@api.mailgun.net/v2/sandbox45cac23aba3c496ab26b566ddae1bd5b.mailgun.org/messages",
          from: Rails.application.secrets.mailgun_sender,
          to: recipient_variables.keys.join(','),
          'recipient-variables' => recipient_variables.to_json,
          subject: subject,
          text: "",
          html: body
      logger.info "Sent a mail to: #{recipient_variables.to_s}"
    rescue => e
      logger.error e.response
    end
  end

  def render(template)
    logger.info template
    Slim::Template.new(template).render()
  end
end
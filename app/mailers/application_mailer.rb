

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@argu.co',
          charset: 'UTF-8',
          content_type: 'text/html'

  add_template_helper(MailerHelper)

end

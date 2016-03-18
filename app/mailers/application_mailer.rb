class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic, AlternativeNamesHelper

  default from: 'noreply@argu.co',
          charset: 'UTF-8',
          content_type: 'text/html'
  layout 'email'

  add_template_helper(MailerHelper)
end

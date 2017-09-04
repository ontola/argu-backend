# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include NamesHelper
  include Roadie::Rails::Automatic

  default from: '"Argu" <noreply@argu.co>',
          charset: 'UTF-8',
          content_type: 'text/html'
  layout 'email'

  add_template_helper(MailerHelper)
end

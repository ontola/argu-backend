# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include NamesHelper
  include Roadie::Rails::Automatic
  add_template_helper(EmailActionsHelper)

  default from: '"Argu" <noreply@argu.co>',
          charset: 'UTF-8',
          content_type: 'text/html'
  layout 'email'
end

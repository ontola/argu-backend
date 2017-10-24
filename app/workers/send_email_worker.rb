# frozen_string_literal: true

require 'argu/api'

class SendEmailWorker
  include Sidekiq::Worker

  def perform(template, recipient, options = {})
    recipient = User.find(recipient) unless recipient.is_a?(Hash)
    Argu::API.service_api.create_email(template, recipient, options)
  end
end

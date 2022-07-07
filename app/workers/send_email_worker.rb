# frozen_string_literal: true

class SendEmailWorker
  include Sidekiq::Worker

  def perform(template, recipient, options = {})
    recipient = recipient.is_a?(Hash) ? recipient.with_indifferent_access : User.find(recipient)
    Argu::API.new.create_email(template, recipient, **options)
  end
end

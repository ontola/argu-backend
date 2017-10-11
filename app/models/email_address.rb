# frozen_string_literal: true

require 'argu/api'

class EmailAddress < ApplicationRecord
  include RedisResourcesHelper
  include Ldable
  TEMP_EMAIL_REGEX = /\Achange@me/

  belongs_to :user, inverse_of: :email_addresses
  before_save :remove_other_primaries
  before_save { |user| user.email = email.downcase if email.present? }
  after_commit :publish_data_event

  validate :dont_update_confirmed_email
  validates :email,
            allow_blank: false,
            format: {with: RFC822::EMAIL}
  validate :newly_secondary_email_not_primary, on: :create
  delegate :greeting, to: :user

  contextualize_as_type 'argu:Email'
  contextualize_with_id { |e| "#{e.user.context_id}/email/#{e.id}" }

  def after_confirmation
    schedule_redis_resource_worker(user, user)
  end

  def confirm
    user.notifications.confirmation_reminder.destroy_all
    super
  end

  def destroy
    super unless primary?
  end

  def email_verified?
    email && email !~ TEMP_EMAIL_REGEX
  end

  def reconfirmation_required?
    email_changed?
  end

  private

  def dont_update_confirmed_email
    return unless persisted? && confirmed? && email_changed?
    errors.add(:email, 'You cannot change a confirmed email')
  end

  def newly_secondary_email_not_primary
    return if !primary? || user.email_addresses.count.zero?
    errors.add(:email, 'You cannot set a new email to primary on creation')
  end

  def postpone_email_change?
    false
  end

  def publish_data_event
    DataEvent.publish(self)
  end

  # Sends a mail with confirmation instructions for secondary emails
  # Confirmation instructions for primary emails are send by the {RegistationsController}
  def send_confirmation_instructions
    return if primary?
    Argu::API
      .service_api
      .create_email(
        :ConfirmationsMailer,
        :confirm_secondary,
        user,
        confirmationToken: confirmation_token,
        email: email
      )
  end

  def remove_other_primaries
    return unless primary?
    user.email_addresses.each do |email|
      next if email == self
      email.update(primary: false)
    end
  end
end

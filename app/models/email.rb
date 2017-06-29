# frozen_string_literal: true
class Email < ApplicationRecord
  include Ldable, RedisResourcesHelper
  TEMP_EMAIL_REGEX = /\Achange@me/

  belongs_to :user, inverse_of: :emails
  before_save :remove_other_primaries
  before_save { |user| user.email = email.downcase unless email.blank? }
  after_commit :publish_data_event

  validate :dont_update_confirmed_email
  validates :email,
            allow_blank: false,
            format: {with: RFC822::EMAIL}
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
    self.class.reconfirmable && (email_changed? || previous_changes.include?(:email)) && email.present?
  end

  private

  def dont_update_confirmed_email
    return unless persisted? && confirmed? && email_changed?
    errors.add(:email, 'You cannot change a confirmed email')
  end

  def postpone_email_change?
    false
  end

  def publish_data_event
    DataEvent.publish(self)
  end

  def remove_other_primaries
    return unless primary?
    user.emails.each do |email|
      next if email == self
      email.update(primary: false)
    end
  end
end

# frozen_string_literal: true

class EmailAddress < ApplicationRecord
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Createable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Updateable, except: %i[Action]
  enhance LinkedRails::Enhancements::Tableable

  include Broadcastable
  include Parentable
  include RedisResourcesHelper
  TEMP_EMAIL_REGEX = /\Achange@me/

  belongs_to :user, inverse_of: :email_addresses
  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }

  before_save :remove_other_primaries
  before_save { |user| user.email = email.downcase if email.present? }
  before_update :send_confirmation_instructions, if: :email_changed?

  with_columns settings: [
    NS::SCHEMA[:email],
    NS::ONTOLA[:makePrimaryAction],
    NS::ONTOLA[:sendConfirmationAction],
    NS::ONTOLA[:destroyAction]
  ]

  parentable :user
  self.default_sortings = [{key: NS::SCHEMA[:email], direction: :asc}]

  validate :dont_update_confirmed_email
  validates :email,
            allow_blank: false,
            format: {with: RegexHelper::EMAIL}
  validate :newly_secondary_email_not_primary, on: :create
  delegate :greeting, to: :user

  def after_confirmation
    user.edges.update_all(confirmed: true)
    Vote.fix_counts
  end

  def confirm
    user.notifications.confirmation_reminder.destroy_all
    user.create_finish_intro_notification
    super
  end

  def destroy
    super unless primary?
  end

  def email_verified?
    email && email !~ TEMP_EMAIL_REGEX
  end

  def reconfirmation_required?
    false
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

  # Sends a mail with confirmation instructions for secondary emails
  # Confirmation instructions for primary emails are send by the {RegistationsController}
  def send_confirmation_instructions
    return if primary?
    SendEmailWorker.perform_async(
      :confirm_secondary,
      user.guest? ? nil : user.id,
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

  class << self
    def input_select_property
      NS::SCHEMA[:email]
    end
  end
end

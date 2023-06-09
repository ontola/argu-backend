# frozen_string_literal: true

class EmailAddress < ApplicationRecord
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Updatable, except: %i[Action]

  include Cacheable
  include RedisResourcesHelper
  include DeltaHelper
  TEMP_EMAIL_REGEX = /\Achange@me/.freeze

  belongs_to :user, inverse_of: :email_addresses
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  before_save :remove_other_primaries
  before_save :clear_reset_password_token, if: :primary_changed?
  before_save { |user| user.email = email.downcase if email.present? }
  before_update :send_confirmation_instructions, if: :email_changed?

  collection_options(
    default_sortings: [{key: NS.schema.email, direction: :asc}]
  )
  with_columns settings: [
    NS.schema.email,
    NS.ontola[:makePrimaryAction],
    NS.ontola[:sendConfirmationAction],
    NS.ontola[:destroyAction]
  ]
  filterable NS.argu[:confirmed] => boolean_filter(
    ->(scope) { scope.where.not(confirmed_at: nil) },
    ->(scope) { scope.where(confirmed_at: nil) }
  )

  validate :dont_update_confirmed_email
  validates :email,
            allow_blank: false,
            uniqueness: true,
            format: {with: RegexHelper::EMAIL}
  validate :newly_secondary_email_not_primary, on: :create

  def after_confirmation
    user.edges.update_all(confirmed: true) # rubocop:disable Rails/SkipsModelValidations
    UserChannel.broadcast_to(user, hex_delta([invalidate_collection_delta(EmailAddress.root_collection)]))
    Vote.fix_counts
  end

  def confirm
    user.notifications.confirmation_reminder.destroy_all
    super
  end

  def destroy # rubocop:disable Rails/ActiveRecordOverride
    super unless primary?
  end

  def email_verified?
    email && email !~ TEMP_EMAIL_REGEX
  end

  def parent_collections(user_context)
    [self.class.root_collection(user_context: user_context)]
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
      token_url: iri_from_template(:user_confirmation, confirmation_token: confirmation_token),
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

  def clear_reset_password_token
    # rubocop:disable Rails/SkipsModelValidations
    user.update_columns(reset_password_token: nil, reset_password_sent_at: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end

  class << self
    def attributes_for_new(opts)
      {user: opts[:user_context]&.user}
    end

    def input_select_property
      NS.schema.email
    end

    def sort_options(_collection)
      [NS.schema.email]
    end
  end
end

# frozen_string_literal: true

class OtpSecret < ApplicationRecord
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable

  belongs_to :user
  has_one_time_password
  attr_accessor :otp_attempt

  validate :validate_otp_attempt, on: %i[update]

  private

  def validate_otp_attempt
    return if persisted? && authenticate_otp(otp_attempt, drift: 60)

    errors.add(:otp_attempt, I18n.t('messages.otp_secrets.invalid'))
  end

  class << self
    def route_key
      'users/otp_secrets'
    end
  end
end

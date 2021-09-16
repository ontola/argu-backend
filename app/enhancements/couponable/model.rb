# frozen_string_literal: true

module Couponable
  module Model
    extend ActiveSupport::Concern

    included do
      property :coupon, :string, NS.argu[:coupon]
      validates :coupon, presence: true, if: :require_coupon?
      validate :validate_coupon
      after_create :invalidate_coupon, if: :coupon
    end

    def require_coupon?
      new_record?
    end

    def require_coupon
      require_coupon?
    end

    private

    def coupon_batch
      @coupon_batch ||= parent.coupon_batches.find_by(coupons: coupon)
    end

    # rubocop:disable Rails/SkipsModelValidations
    def invalidate_coupon
      Property.find_by!(
        edge: coupon_batch,
        predicate: NS.argu[:coupons],
        string: coupon
      ).update_column(:predicate, NS.argu[:usedCoupons])
    end
    # rubocop:enable Rails/SkipsModelValidations

    def validate_coupon
      return if !require_coupon? || coupon_batch.present?

      errors.add(:coupon, I18n.t('coupon_batches.errors.coupon.invalid'))
    end
  end
end

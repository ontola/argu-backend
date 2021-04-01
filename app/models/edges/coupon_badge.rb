# frozen_string_literal: true

class CouponBadge < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Tableable
  parentable :budget_shop

  with_columns default: [
    NS::SCHEMA.name,
    NS::ARGU[:couponCount],
    NS::SCHEMA.dateCreated
  ]

  before_create :generate_tokens

  property :display_name, :string, NS::SCHEMA[:name]
  property :coupons, :string, NS::ARGU[:coupons], array: true
  property :used_coupons, :string, NS::ARGU[:usedCoupons], array: true
  property :coupon_count, :integer, NS::ARGU[:couponCount], default: 0

  private

  def generate_token
    token = SecureRandom.urlsafe_base64(128).upcase.scan(/[123456789ACDEFGHJKLMNPQRTUVWXYZ]+/).join
    token.length >= 8 ? token[0...8] : generate_token
  end

  def generate_tokens
    self.coupons = coupon_count.times.map { generate_token }
  end

  class << self
    def default_collection_display
      :table
    end
  end
end

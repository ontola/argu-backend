# frozen_string_literal: true

class CouponBatch < Edge
  enhance LinkedRails::Enhancements::Creatable
  parentable :budget_shop

  with_columns default: [
    NS.schema.name,
    NS.argu[:couponCount],
    NS.schema.dateCreated
  ]

  before_create :generate_tokens

  property :display_name, :string, NS.schema.name
  property :coupons, :string, NS.argu[:coupons], array: true, preload: false
  property :used_coupons, :string, NS.argu[:usedCoupons], array: true, preload: false
  property :coupon_count, :integer, NS.argu[:couponCount], default: 0

  private

  def generate_token
    token = SecureRandom.urlsafe_base64(128).upcase.scan(/[123456789ACDEFGHJKLMNPQRTUVWXYZ]+/).join
    token.length >= 8 ? token[0...8] : generate_token
  end

  def generate_tokens
    self.coupons = coupon_count.times.map { generate_token }
  end

  def should_broadcast_changes
    false
  end

  class << self
    def default_collection_display
      :table
    end
  end
end

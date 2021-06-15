# frozen_string_literal: true

class Order < Edge
  enhance LinkedRails::Enhancements::Creatable
  parentable :budget_shop
  after_commit :clear_cart!

  property :coupon, :string, NS::ARGU[:coupon]
  validates :coupon, presence: true
  validate :validate_coupon
  after_create :invalidate_token
  attr_accessor :cart

  def added_delta # rubocop:disable Metrics/AbcSize
    [
      [cart.iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
      [parent.order_collection.action(:create).iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
      [NS::SP[:Variable], RDF.type, NS::ONTOLA['Create::CartDetail'], delta_iri(:invalidate)],
      [NS::SP[:Variable], RDF.type, NS::ONTOLA['Destroy::CartDetail'], delta_iri(:invalidate)]
    ]
  end

  private

  def clear_cart!
    cart.cart_details.each(&:destroy)
  end

  def coupon_badge
    @coupon_badge ||= parent.coupon_badges.find_by(coupons: coupon)
  end

  def invalidate_token
    Property.find_by!(
      edge: coupon_badge,
      predicate: NS::ARGU[:coupons].to_s,
      string: coupon
    ).update!(predicate: NS::ARGU[:usedCoupons].to_s)
  end

  def validate_coupon
    return if coupon_badge.present?

    errors.add(:coupon, I18n.t('orders.errors.coupon.invalid'))
  end

  class << self
    def interact_as_guest?
      true
    end
  end
end

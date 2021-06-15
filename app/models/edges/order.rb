# frozen_string_literal: true

class Order < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Tableable
  parentable :budget_shop
  after_commit :clear_cart!
  delegate :currency, to: :parent

  property :coupon, :string, NS::ARGU[:coupon]
  validates :coupon, presence: true
  validate :validate_coupon
  after_create :invalidate_token
  attr_accessor :cart

  with_collection :order_details
  with_columns default: [
    NS::SCHEMA.creator,
    NS::ARGU[:orderDetails],
    NS::ARGU[:price],
    NS::SCHEMA.dateCreated
  ]

  def added_delta # rubocop:disable Metrics/AbcSize
    [
      [cart.iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
      [parent.order_collection.action(:create).iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
      [NS::SP[:Variable], RDF.type, NS::ONTOLA['Create::CartDetail'], delta_iri(:invalidate)],
      [NS::SP[:Variable], RDF.type, NS::ONTOLA['Destroy::CartDetail'], delta_iri(:invalidate)]
    ]
  end

  def display_name
    I18n.t('orders.type')
  end

  def total_value
    @total_value ||= Money.new(order_details_values.sum, currency)
  end

  private

  def clear_cart!
    cart.cart_details.each(&:destroy)
  end

  def coupon_batch
    @coupon_batch ||= parent.coupon_batches.find_by(coupons: coupon)
  end

  def invalidate_token
    Property.find_by!(
      edge: coupon_batch,
      predicate: NS::ARGU[:coupons].to_s,
      string: coupon
    ).update!(predicate: NS::ARGU[:usedCoupons].to_s)
  end

  def order_details_values
    order_details.map { |detail| detail.offer.price }
  end

  def validate_coupon
    return if coupon_batch.present?

    errors.add(:coupon, I18n.t('orders.errors.coupon.invalid'))
  end

  class << self
    def default_collection_display
      :table
    end

    def interact_as_guest?
      true
    end
  end
end

# frozen_string_literal: true

class CartDetail < Edge
  include DeltaHelper
  include RedisResource::Concern

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Indexable

  attribute :shop_id
  parentable :budget_shop, :offer

  delegate :display_name, to: :parent

  def anonymous_iri?
    false
  end

  def iri_opts
    super.merge(
      parent_iri: split_iri_segments(ancestor(:budget_shop)&.cart_for(publisher)&.root_relative_iri),
      uuid: uuid
    )
  end

  def added_delta
    data = super
    user_context = UserContext.new(user: publisher, profile: creator)
    data.concat(reset_offer_action_status(parent, user_context))
    data.concat(cart_delta(user_context))
    data
  end
  alias removed_delta added_delta

  def shop
    parent.parent
  end

  private

  def cart_delta(user_context)
    cart = shop.cart_for(publisher)
    order_action = shop.order_collection.action(:create, user_context)
    [
      reset_action_error(order_action),
      reset_action_status(order_action),
      [cart.iri, NS::SCHEMA.totalPaymentDue, cart.total_value&.cents, delta_iri(:replace)]
    ]
  end

  def reset_action_error(action)
    if action.error
      [action.iri, NS::SCHEMA.error, action.error, delta_iri(:replace)]
    else
      [action.iri, NS::SCHEMA.error, NS::SP[:Variable], delta_iri(:remove)]
    end
  end

  def reset_action_status(action)
    [action.iri, NS::SCHEMA.actionStatus, action.action_status, delta_iri(:replace)]
  end

  def reset_offer_action_status(offer, user_context)
    %i[create destroy].map do |tag|
      reset_action_status(offer.cart_detail_collection.action(tag, user_context))
    end
  end

  class << self
    def attributes_for_new(opts)
      super.merge(
        parent: opts[:parent].is_a?(Cart) ? opts[:parent].parent : opts[:parent],
        shop_id: opts[:parent]&.parent&.id
      )
    end

    def default_filters
      {}
    end

    def store_in_redis?(_opts = {})
      true
    end

    def sort_options(_collection)
      []
    end
  end
end

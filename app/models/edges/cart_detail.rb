# frozen_string_literal: true

class CartDetail < Edge
  include DeltaHelper
  include RedisResource::Concern

  enhance LinkedRails::Enhancements::Creatable

  attribute :shop_id
  parentable :budget_shop, :offer

  delegate :display_name, to: :parent

  def anonymous_iri?
    false
  end

  def iri_opts
    super.merge(parent_iri: parent_iri_path)
  end

  def added_delta
    data = super
    user_context = UserContext.new(user: publisher, profile: creator)
    data.concat(reset_offer_action_status(parent, user_context))
    data.concat(cart_delta)
    data
  end
  alias removed_delta added_delta

  private

  def cart_delta
    cart = parent.parent.cart_for(publisher)
    [
      [cart.iri, NS::SCHEMA.totalPaymentDue, cart.total_value, delta_iri(:replace)]
    ]
  end

  def reset_action_status(action)
    [action.iri, NS::SCHEMA[:actionStatus], action.action_status, delta_iri(:replace)]
  end

  def reset_offer_action_status(offer, user_context)
    %i[create destroy].map do |tag|
      reset_action_status(offer.cart_detail_collection.action(tag, user_context))
    end
  end

  class << self
    def store_in_redis?(_opts = {})
      true
    end
  end
end

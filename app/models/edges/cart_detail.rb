# frozen_string_literal: true

class CartDetail < Edge
  include DeltaHelper
  include RedisResource::Concern

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Singularable

  collection_options(
    default_filters: {},
    include_members: true
  )
  attribute :shop_id
  parentable :budget_shop, :offer

  delegate :display_name, to: :parent

  def added_delta
    data = super
    user_context = UserContext.new(user: publisher, profile: creator)
    data.concat(reset_offer_action_status(user_context))
    data.concat(cart_delta(user_context))
    data
  end

  def cacheable?
    false
  end

  def shop
    parent.parent
  end

  private

  def cart_delta(user_context)
    cart = shop.cart_for(user_context)
    order_action = shop.order_collection(user_context: user_context).action(:create, user_context)
    [
      reset_action_error(order_action),
      reset_action_status(order_action),
      [cart.iri, NS.schema.totalPaymentDue, cart.total_value&.cents, delta_iri(:replace)]
    ]
  end

  def reset_action_error(action)
    if action.error
      [action.iri, NS.schema.error, action.error, delta_iri(:replace)]
    else
      [action.iri, NS.schema.error, NS.sp.Variable, delta_iri(:remove)]
    end
  end

  def reset_action_status(action)
    [action.iri, NS.schema.actionStatus, action.action_status, delta_iri(:replace)]
  end

  def reset_offer_action_status(user_context)
    %i[create destroy].map { |tag| reset_action_status(action(tag, user_context)) }
  end

  class << self
    def attributes_for_new(opts)
      super.merge(
        parent: opts[:parent].is_a?(Cart) ? opts[:parent].parent : opts[:parent],
        shop_id: opts[:parent]&.parent&.id
      )
    end

    def singular_route_key
      :cart_detail
    end

    def requested_singular_resource(params, user_context)
      parent = parent_from_params(params, user_context)

      CartDetail.where_with_redis(publisher: user_context.user, parent: parent).first ||
        CartDetail.new(publisher: user_context.user, parent: parent, shop_id: parent.parent.id)
    end

    def store_in_redis?(**_opts)
      true
    end

    def sort_options(_collection)
      []
    end
  end
end

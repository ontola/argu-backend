# frozen_string_literal: true

class Cart < VirtualResource
  extend UriTemplateHelper

  enhance Singularable
  include Parentable
  include IRITemplateHelper
  attr_accessor :shop, :user

  parentable :shop
  alias edgeable_record shop
  alias id root_relative_iri

  with_collection :cart_details

  delegate :budget_max, :currency, to: :shop

  def budget_exceeded?
    total_value > budget_max
  end

  def cart_details
    @cart_details ||=
      CartDetail.where_with_redis(
        publisher: user,
        shop_id: shop.id
      )
  end

  def iri
    singular_iri
  end

  def singular_iri_opts
    {
      parent_iri: parent_iri_path
    }
  end

  def total_value
    @total_value ||= Money.new(cart_details_values.map { |value| Money.new(value, currency) }.sum, currency)
  end

  private

  def cart_details_values
    Property
      .joins(:edge)
      .where(
        edges: {id: cart_details.map(&:parent_id)},
        predicate: NS::ARGU[:price].to_s
      )
      .pluck(:integer)
  end

  class << self
    def singular_iri_template
      uri_template(:carts_iri)
    end

    def singular_resource(params, user_context)
      parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)

      Cart.new(
        shop: parent,
        user: user_context.user
      )
    end
  end
end

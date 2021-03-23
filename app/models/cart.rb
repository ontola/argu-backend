# frozen_string_literal: true

class Cart < VirtualResource
  include Parentable
  include IRITemplateHelper
  attr_accessor :shop, :user

  parentable :shop
  alias edgeable_record shop
  alias id iri_path

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

  def iri_opts
    super.merge(parent_iri: parent_iri_path)
  end

  def total_value
    @total_value ||=
      Property
        .joins(:edge)
        .where(
          edges: {id: cart_details.map(&:parent_id)},
          predicate: NS::SCHEMA.price.to_s
        )
        .sum(:integer)
        .to_i
  end
end

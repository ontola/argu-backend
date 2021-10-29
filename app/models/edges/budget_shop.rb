# frozen_string_literal: true

class BudgetShop < Discussion
  enhance Shopable
  enhance CouponBatchable

  include Edgeable::Content

  property :budget_max, :integer, NS.argu[:budgetMax]
  property :currency, :string, NS.schema.priceCurrency, default: 'EUR'
  parentable :container_node, :page, :phase

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :currency, inclusion: Money::Currency.table.keys.map { |cur| cur.to_s.upcase }

  def budget_max
    Money.new(super, currency) if super
  end

  def cart_for(user_context)
    Cart.new(shop: self, user_context: user_context)
  end

  class << self
    def iri
      [super, NS.argu[:Shop]]
    end

    def route_key
      :budgets
    end
  end
end

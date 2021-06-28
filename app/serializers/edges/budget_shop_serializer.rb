# frozen_string_literal: true

class BudgetShopSerializer < DiscussionSerializer
  money_attribute :budget_max, predicate: NS.argu[:budgetMax]
  attribute :cart_iri, predicate: NS.argu[:cart] do |object|
    Cart.new(shop: object).iri
  end
end

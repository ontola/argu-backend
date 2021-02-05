# frozen_string_literal: true

class BudgetShopSerializer < DiscussionSerializer
  attribute :budget_max, predicate: NS::ARGU[:budgetMax]
  attribute :currency, predicate: NS::SCHEMA.priceCurrency
end

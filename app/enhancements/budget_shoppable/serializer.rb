# frozen_string_literal: true

module BudgetShoppable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :budget_shops, predicate: NS::ARGU[:budgetShops]
    end
  end
end

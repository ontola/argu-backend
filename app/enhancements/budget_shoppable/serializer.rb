# frozen_string_literal: true

module BudgetShoppable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :budget_shops, predicate: NS.argu[:budgetShops]
    end
  end
end

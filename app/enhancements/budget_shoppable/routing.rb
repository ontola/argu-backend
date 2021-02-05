# frozen_string_literal: true

module BudgetShoppable
  module Routing; end

  class << self
    def dependent_classes
      [BudgetShop]
    end

    def route_concerns(mapper)
      mapper.concern :budget_shoppable do
        mapper.resources :budget_shops, only: %i[index new create], path: :budgets do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module BudgetShoppable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :budget_shops
    end
  end
end

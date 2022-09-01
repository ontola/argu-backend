# frozen_string_literal: true

class BudgetShopPolicy < EdgePolicy
  permit_attributes %i[display_name description currency budget_max]
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator]
end

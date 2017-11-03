# frozen_string_literal: true

class MenuListSerializer < BaseSerializer
  has_many :menus, predicate: NS::ARGU[:menus]
end

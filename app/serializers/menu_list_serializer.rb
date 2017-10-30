# frozen_string_literal: true

class MenuListSerializer < BaseSerializer
  has_many :menus, predicate: RDF::ARGU[:menus]
end

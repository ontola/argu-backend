# frozen_string_literal: true

class GrantSetSerializer < BaseSerializer
  has_many :permitted_actions, predicate: NS::ARGU[:permittedAction]
  attribute :display_name, predicate: NS::SCHEMA[:name], graph: NS::LL[:add]
end

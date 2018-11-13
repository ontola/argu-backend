# frozen_string_literal: true

class GrantSetSerializer < BaseSerializer
  has_many :permitted_actions, predicate: NS::ARGU[:permittedAction]
  attribute :display_name, predicate: NS::SCHEMA[:name], graph: NS::LL[:add]

  def display_name
    I18n.t("roles.types.#{object.title}").capitalize
  end
end

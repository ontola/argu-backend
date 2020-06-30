# frozen_string_literal: true

class GrantSetSerializer < BaseSerializer
  has_many :permitted_actions, predicate: NS::ARGU[:permittedAction]
  attribute :display_name, predicate: NS::SCHEMA[:name]
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :title, predicate: NS::ARGU[:grantSetKey] do |object|
    object.title&.to_sym
  end
end

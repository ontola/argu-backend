# frozen_string_literal: true

class GrantSetSerializer < BaseSerializer
  has_many :permitted_actions, predicate: NS.argu[:permittedAction]
  attribute :display_name, predicate: NS.schema.name
  attribute :description, predicate: NS.schema.text
  attribute :title, predicate: NS.argu[:grantSetKey] do |object|
    object.title&.to_sym
  end
end

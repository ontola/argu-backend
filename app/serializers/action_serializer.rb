# frozen_string_literal: true

class ActionSerializer < BaseSerializer
  attribute :target, predicate: NS::SCHEMA[:target]
  attribute :name, predicate: NS::SCHEMA[:name]

  def type
    NS::SCHEMA[object.type]
  end
end

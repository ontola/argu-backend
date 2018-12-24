# frozen_string_literal: true

class CreativeWorkSerializer < EdgeSerializer
  attribute :display_name, predicate: NS::SCHEMA[:name]
  attribute :description, predicate: NS::SCHEMA[:text]
end

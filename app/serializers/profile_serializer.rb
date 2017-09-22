# frozen_string_literal: true

class ProfileSerializer < BaseSerializer
  include Photoable::Serializer
  attribute :display_name, predicate: NS::SCHEMA[:name]
end

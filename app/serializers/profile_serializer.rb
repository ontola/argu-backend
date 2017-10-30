# frozen_string_literal: true

class ProfileSerializer < BaseSerializer
  attribute :display_name, predicate: RDF::SCHEMA[:name]
end

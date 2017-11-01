# frozen_string_literal: true

class GuestUserSerializer < BaseSerializer
  attribute :display_name, predicate: RDF::SCHEMA[:name]

  def type
    RDF::SCHEMA[:Person]
  end
end

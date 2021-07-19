# frozen_string_literal: true

class ThingSerializer < RecordSerializer
  attribute :granted_sets_iri, predicate: NS.argu[:grantedSets], if: method(:never)
  attribute :organization, predicate: NS.ontola[:organization], if: method(:never)

  statements :property_statements

  def self.property_statements(object, _params)
    object.property_statements
  end
end

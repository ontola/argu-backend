# frozen_string_literal: true

class PropertyDefinitionSerializer < BaseSerializer
  has_one :vocabulary, predicate: NS.schema[:isPartOf]
  attribute :predicate, predicate: NS.app[:predicate]
  enum :property_type, predicate: NS.app[:propertyType]
end

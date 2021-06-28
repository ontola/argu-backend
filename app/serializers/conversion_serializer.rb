# frozen_string_literal: true

class ConversionSerializer < BaseSerializer
  attribute :klass_iri,
            datatype: NS.xsd.string,
            predicate: NS.argu[:convertToClass]
  has_many :convertible_classes,
           sequence: true,
           predicate: NS.argu[:convertibleClasses]
end

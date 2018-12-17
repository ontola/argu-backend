# frozen_string_literal: true

class ConversionSerializer < BaseSerializer
  attribute :klass, datatype: NS::XSD[:string], predicate: NS::ARGU[:convertToClass]
end

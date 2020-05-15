# frozen_string_literal: true

class ShortnameSerializer < RecordSerializer
  has_one :owner, predicate: NS::ARGU[:shortnameable], polymorphic: true
  attribute :path, predicate: NS::ARGU[:alias]
  attribute :shortname, predicate: NS::ARGU[:shortname]
  attribute :destination, predicate: NS::ARGU[:destination], if: method(:never), datatype: NS::XSD[:string]
  attribute :unscoped, predicate: NS::ARGU[:unscoped], if: method(:never), datatype: NS::XSD[:boolean]
end

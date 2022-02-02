# frozen_string_literal: true

class ShortnameSerializer < RecordSerializer
  has_one :owner, predicate: NS.argu[:shortnameable]
  attribute :path, predicate: NS.argu[:alias]
  attribute :shortname, predicate: NS.argu[:shortname]
  attribute :destination, predicate: NS.argu[:destination], if: method(:never), datatype: NS.xsd.string
  attribute :unscoped, predicate: NS.argu[:unscoped], if: method(:never), datatype: NS.xsd.boolean
end

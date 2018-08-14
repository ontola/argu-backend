# frozen_string_literal: true

class PlacementSerializer < RecordSerializer
  attribute :postal_code, predicate: NS::SCHEMA[:postalCode]
  attribute :country_code, predicate: NS::SCHEMA[:addressCountry]
end

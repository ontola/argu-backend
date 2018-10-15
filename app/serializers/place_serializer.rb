# frozen_string_literal: true

class PlaceSerializer < BaseSerializer
  attribute :lat, predicate: NS::SCHEMA[:latitude]
  attribute :lon, predicate: NS::SCHEMA[:longitude]
  attribute :country_code, predicate: NS::SCHEMA[:addressCountry]
  attribute :postal_code, predicate: NS::SCHEMA[:postalCode]
  attribute :zoom_level, predicate: NS::ARGU[:zoomLevel]
  attribute :display_name, predicate: NS::SCHEMA[:name]
end

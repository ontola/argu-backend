# frozen_string_literal: true

class PlaceSerializer < BaseSerializer
  attribute :lat, predicate: NS.schema.latitude
  attribute :lon, predicate: NS.schema.longitude
  attribute :country_code, predicate: NS.schema.addressCountry
  attribute :postal_code, predicate: NS.schema.postalCode
  attribute :zoom_level, predicate: NS.argu[:zoomLevel]
  attribute :display_name, predicate: NS.schema.name
end

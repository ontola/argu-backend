# frozen_string_literal: true

class PlacementSerializer < RecordSerializer
  extend NamesHelper

  attribute :coordinates, predicate: NS::ARGU[:geoCoordinates], if: method(:never)
  attribute :image, predicate: NS::SCHEMA[:image] do |object|
    image =
      if object.placement_type == 'custom'
        icon = icon_for(object.placeable)
        :"fa-#{icon}" if icon
      elsif object.placement_type == 'home'
        :'fa-home'
      end

    serialize_image(image) if image
  end

  has_one :place, predicate: NS::SCHEMA[:geo]
  has_one :placeable, predicate: NS::ARGU[:placeable], polymorphic: true

  attribute :country_code, predicate: NS::SCHEMA[:addressCountry]
  attribute :placement_type, predicate: NS::ARGU[:placementType]
  attribute :postal_code, predicate: NS::SCHEMA[:postalCode]

  attribute :lat, predicate: NS::SCHEMA[:latitude]
  attribute :lon, predicate: NS::SCHEMA[:longitude]
  attribute :zoom_level, predicate: NS::ARGU[:zoomLevel]
end

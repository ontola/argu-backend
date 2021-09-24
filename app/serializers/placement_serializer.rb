# frozen_string_literal: true

class PlacementSerializer < RecordSerializer
  attribute :coordinates, predicate: NS.argu[:geoCoordinates], if: method(:never)
  attribute :image, predicate: NS.schema.image do |object|
    image =
      case object.placement_type
      when 'custom'
        icon = LinkedRails.translate(:class, :icon, object.placeable.class.iri) if object.placeable
        :"fa-#{icon}" if icon
      when 'home'
        :'fa-home'
      end

    serialize_image(image) if image
  end

  has_one :place, predicate: NS.schema.geo
  has_one :placeable, predicate: NS.schema.isPartOf, polymorphic: true

  attribute :country_code, predicate: NS.schema.addressCountry
  attribute :placement_type, predicate: NS.argu[:placementType]
  attribute :postal_code, predicate: NS.schema.postalCode

  attribute :lat, predicate: NS.schema.latitude
  attribute :lon, predicate: NS.schema.longitude
  attribute :zoom_level, predicate: NS.ontola[:zoomLevel]
end

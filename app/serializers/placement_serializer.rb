# frozen_string_literal: true

class PlacementSerializer < RecordSerializer
  attribute :coordinates, predicate: NS.argu[:geoCoordinates], if: method(:never)
  attribute :image, predicate: NS.schema.image do |object|
    klass_iri = object.edge&.class&.iri
    image = LinkedRails.translate(:class, :icon, klass_iri) if klass_iri.is_a?(RDF::URI)

    serialize_image(:"fa-#{image}") if image
  end
  has_one :parent, predicate: NS.schema.isPartOf
  attribute :lat, predicate: NS.schema.latitude
  attribute :lon, predicate: NS.schema.longitude
  attribute :zoom_level, predicate: NS.ontola[:zoomLevel]
end

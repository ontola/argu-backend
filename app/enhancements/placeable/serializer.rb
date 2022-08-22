# frozen_string_literal: true

module Placeable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_one :placement,
              predicate: NS.schema.location
      has_one :location_query,
              predicate: NS.argu[:locationQuery],
              unless: method(:export_scope?)

      attribute :lat, if: method(:export_scope?) do |object|
        object.placement&.lat
      end
      attribute :lon, if: method(:export_scope?) do |object|
        object.placement&.lon
      end
    end
  end
end

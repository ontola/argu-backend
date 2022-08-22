# frozen_string_literal: true

module Placeable
  module Model
    extend ActiveSupport::Concern
    include DeltaHelper

    included do
      has_one :placement,
              dependent: :destroy,
              primary_key: :uuid,
              foreign_key: :edge_id
      accepts_nested_attributes_for :placement, allow_destroy: true
      validates :placement, presence: true, if: :requires_location?
    end

    def added_delta
      return super unless try(:parent).respond_to?(:children_placement_collection)

      super + [
        invalidate_collection_delta(parent.children_placement_collection)
      ]
    end

    def location_query
      return if location_query_iri.blank?

      @location_query ||= LinkedRails::PropertyQuery.new(
        iri: location_query_iri,
        force_render: true,
        target_node: iri,
        path: NS.schema.location
      )
    end

    def location_query_iri
      LinkedRails.iri(path: root_relative_iri, fragment: 'location') unless anonymous_iri?
    end

    def requires_location?
      false
    end
  end
end

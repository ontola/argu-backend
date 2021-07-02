# frozen_string_literal: true

module Placeable
  module Model
    extend ActiveSupport::Concern

    included do
      class_attribute :placeable_types, default: []

      has_many :placements, as: :placeable, dependent: :destroy, primary_key: :uuid
      has_many :places, through: :placements
      accepts_nested_attributes_for :placements, allow_destroy: true
    end

    def added_delta
      return super unless try(:parent).respond_to?(:children_placements_iri)

      super + [
        [parent.children_placements_iri, NS.sp.Variable, NS.sp.Variable, NS.ontola[:invalidate]]
      ]
    end
    alias removed_delta added_delta

    def requires_location?
      false
    end

    module ClassMethods
      def attributes_from_filters(filters)
        custom_placement_attributes = Placement.attributes_from_filters(filters)
        return super if custom_placement_attributes.blank?

        super.merge(custom_placement_attributes: custom_placement_attributes.merge(placement_type: 'custom'))
      end

      def define_placement_associations(type)
        class_name = type == :home ? 'HomePlacement' : 'Placement'
        has_one "#{type}_placement".to_sym,
                -> { send(type) },
                as: :placeable,
                class_name: class_name,
                primary_key: :uuid
        accepts_nested_attributes_for "#{type}_placement".to_sym, reject_if: :all_blank, allow_destroy: true

        validates :custom_placement, presence: true, if: :requires_location? if type == :custom
      end

      def placeable(*types)
        self.placeable_types = types
        types.each(&method(:define_placement_associations))
      end
    end
  end
end

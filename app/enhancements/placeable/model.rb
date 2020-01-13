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
      return super unless parent.respond_to?(:children_placements_iri)

      super + [
        [parent.children_placements_iri, NS::SP[:Variable], NS::SP[:Variable], NS::ONTOLA[:invalidate]]
      ]
    end
    alias removed_delta added_delta

    def requires_location?
      is_a?(Edge) && owner_type == 'Motion' && parent.owner_type == 'Question' && parent.require_location
    end

    module ClassMethods
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

      def includes_for_serializer
        super.merge(Hash[placeable_types.map { |type| ["#{type}_placement".to_sym, :place] }])
      end

      def placeable(*types)
        self.placeable_types = types
        types.each(&method(:define_placement_associations))
      end

      def show_includes
        super + placeable_types.map { |type| {"#{type}_placement".to_sym => :place} }
      end
    end
  end
end

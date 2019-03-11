# frozen_string_literal: true

module Placeable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :placements, as: :placeable, dependent: :destroy, primary_key: :uuid
      has_one :custom_placement,
              -> { custom },
              class_name: 'Placement',
              as: :placeable,
              inverse_of: :placeable,
              primary_key: :uuid
      has_one :country_placement,
              -> { country },
              class_name: 'Placement',
              as: :placeable,
              inverse_of: :placeable,
              primary_key: :uuid
      has_one :home_placement,
              -> { home },
              as: :placeable,
              inverse_of: :placeable,
              primary_key: :uuid
      has_many :places, through: :placements
      accepts_nested_attributes_for :placements, allow_destroy: true
      accepts_nested_attributes_for :custom_placement, allow_destroy: true

      validates :custom_placement, presence: true, if: :requires_location?
    end

    def requires_location?
      is_a?(Edge) && owner_type == 'Motion' && parent.owner_type == 'Question' && parent.require_location
    end

    module ClassMethods
      def includes_for_serializer
        super.merge(custom_placement: :place)
      end

      def show_includes
        super + [
          custom_placement: :place
        ]
      end
    end
  end
end

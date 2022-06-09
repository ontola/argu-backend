# frozen_string_literal: true

module Placeable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes(Placement.placement_types.keys.map { |key| :"#{key}_placement" })
    end

    def permitted_attributes_from_filters(filters)
      custom_placement_attributes = params_parser(filters).attributes_from_filters(Placement).permit!
      return super if custom_placement_attributes.blank?

      super.merge(custom_placement_attributes: custom_placement_attributes.merge(placement_type: 'custom'))
    end
  end
end

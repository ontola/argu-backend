# frozen_string_literal: true

module Placeable
  module Controller
    def parsed_filter_params
      custom_placement_attributes = params_parser.attributes_from_filters(Placement)
      return super if custom_placement_attributes.blank?

      super.merge(custom_placement_attributes: custom_placement_attributes.merge(placement_type: 'custom'))
    end
  end
end

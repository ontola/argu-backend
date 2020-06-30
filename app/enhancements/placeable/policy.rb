# frozen_string_literal: true

module Placeable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes(Placement.placement_types.keys.map { |key| :"#{key}_placement" })
    end
  end
end

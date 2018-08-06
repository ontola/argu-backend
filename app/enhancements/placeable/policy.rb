# frozen_string_literal: true

module Placeable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(placements_attributes: %i[id lat lon placement_type zoom_level _destroy])
      attributes
    end
  end
end

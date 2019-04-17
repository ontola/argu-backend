# frozen_string_literal: true

module Placeable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      record.class.placeable_types.each do |type|
        attributes.append("#{type}_placement_attributes".to_sym => %i[id lat lon placement_type zoom_level _destroy])
      end
      attributes
    end
  end
end

# frozen_string_literal: true

module Placeable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[placement]
    end

    def permitted_attributes_from_filters(filters)
      placement_attributes = params_parser(filters).attributes_from_filters(Placement).permit!
      return super if placement_attributes.blank?

      super.merge(placement_attributes: placement_attributes)
    end
  end
end

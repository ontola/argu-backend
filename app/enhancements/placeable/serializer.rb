# frozen_string_literal: true

module Placeable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_one :custom_placement,
              predicate: NS.schema.location,
              if: method(:has_custom_placement?)
      has_one :home_placement,
              predicate: NS.schema.homeLocation,
              if: method(:has_home_placement?)
    end

    class_methods do
      def has_custom_placement?(_object, _params)
        serializable_class.placeable_types.include?(:custom)
      end

      def has_home_placement?(object, params)
        serializable_class.placeable_types.include?(:home) && self?(object, params)
      end
    end
  end
end

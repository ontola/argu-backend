# frozen_string_literal: true

module Placeable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_one :custom_placement, predicate: NS::SCHEMA[:location], image: 'map-marker', if: :has_custom_placement?
      has_one :home_placement, predicate: NS::SCHEMA[:homeLocation], if: :has_home_placement?
    end

    def has_custom_placement?
      serializable_class.placeable_types.include?(:custom)
    end

    def has_home_placement?
      serializable_class.placeable_types.include?(:home) && self?
    end
  end
end

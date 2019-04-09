# frozen_string_literal: true

module Placeable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_one :custom_placement,
              predicate: NS::SCHEMA[:location],
              image: 'map-marker'
    end
  end
end

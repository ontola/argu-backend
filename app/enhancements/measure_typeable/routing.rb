# frozen_string_literal: true

module MeasureTypeable
  module Routing; end

  class << self
    def dependent_classes
      [MeasureType]
    end

    def route_concerns(mapper)
      mapper.concern :measure_typeable do
        mapper.resources :measure_types, only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

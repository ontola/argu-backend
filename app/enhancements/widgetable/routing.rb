# frozen_string_literal: true

module Widgetable
  module Routing; end

  class << self
    def dependent_classes
      [Widget]
    end

    def route_concerns(mapper)
      mapper.concern :widgetable do
        mapper.resources :widgets, only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

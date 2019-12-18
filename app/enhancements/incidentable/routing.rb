# frozen_string_literal: true

module Incidentable
  module Routing; end

  class << self
    def dependent_classes
      [Incident]
    end

    def route_concerns(mapper)
      mapper.concern :incidentable do
        mapper.resources :incidents, only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

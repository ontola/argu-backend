# frozen_string_literal: true

module InterventionTypeable
  module Routing; end

  class << self
    def dependent_classes
      [InterventionType]
    end

    def route_concerns(mapper)
      mapper.concern :intervention_typeable do
        mapper.resources :intervention_types, path: 'interventie_types', only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

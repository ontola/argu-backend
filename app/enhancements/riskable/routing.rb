# frozen_string_literal: true

module Riskable
  module Routing; end

  class << self
    def dependent_classes
      [Intervention]
    end

    def route_concerns(mapper)
      mapper.concern :riskable do
        mapper.resources :risks, path: 'gevaren', only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

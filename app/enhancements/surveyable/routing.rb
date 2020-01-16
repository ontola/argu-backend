# frozen_string_literal: true

module Surveyable
  module Routing; end

  class << self
    def dependent_classes
      [Survey]
    end

    def route_concerns(mapper)
      mapper.concern :surveyable do
        mapper.resources :surveys, only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

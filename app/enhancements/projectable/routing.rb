# frozen_string_literal: true

module Projectable
  module Routing; end

  class << self
    def dependent_classes
      [Project]
    end

    def route_concerns(mapper)
      mapper.concern :projectable do
        mapper.resources :projects, only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
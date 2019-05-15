# frozen_string_literal: true

module Questionable
  module Routing; end

  class << self
    def dependent_classes
      [Question]
    end

    def route_concerns(mapper)
      mapper.concern :questionable do
        mapper.resources :questions, path: 'q', only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

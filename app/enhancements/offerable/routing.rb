# frozen_string_literal: true

module Offerable
  module Routing; end

  class << self
    def dependent_classes
      [Offer]
    end

    def route_concerns(mapper)
      mapper.concern :offerable do
        mapper.resources :offers, only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end

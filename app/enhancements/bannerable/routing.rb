# frozen_string_literal: true

module Bannerable
  module Routing; end

  class << self
    def dependent_classes
      [Banner]
    end

    def route_concerns(mapper)
      mapper.concern :bannerable do
        mapper.resources :banners, only: %i[index new create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
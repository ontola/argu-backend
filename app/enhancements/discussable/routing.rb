# frozen_string_literal: true

module Discussable
  module Routing; end

  class << self
    def dependent_classes
      [Discussion]
    end

    def route_concerns(mapper)
      mapper.concern :discussable do
        mapper.resources :discussions, only: %i[index]
      end
    end
  end
end

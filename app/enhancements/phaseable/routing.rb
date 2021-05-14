# frozen_string_literal: true

module Phaseable
  module Routing; end

  class << self
    def dependent_classes
      [Phase]
    end

    def route_concerns(mapper)
      mapper.concern :phaseable do
        mapper.resources :phases, only: %i[index new create]
      end
    end
  end
end

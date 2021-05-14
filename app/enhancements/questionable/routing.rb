# frozen_string_literal: true

module Questionable
  module Routing; end

  class << self
    def dependent_classes
      [Question]
    end

    def route_concerns(mapper)
      mapper.concern :questionable do
        mapper.resources :questions, path: 'q', only: %i[index new create]
      end
    end
  end
end

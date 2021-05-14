# frozen_string_literal: true

module CreativeWorkable
  module Routing; end

  class << self
    def dependent_classes
      [CreativeWork]
    end

    def route_concerns(mapper)
      mapper.concern :creative_workable do
        mapper.resources :creative_works, only: %i[index new create]
      end
    end
  end
end

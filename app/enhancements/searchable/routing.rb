# frozen_string_literal: true

module Searchable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :searchable do
        mapper.resources :search,
                         path: :search,
                         only: :index
      end
    end
  end
end

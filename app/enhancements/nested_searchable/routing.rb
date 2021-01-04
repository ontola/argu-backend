# frozen_string_literal: true

module NestedSearchable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :nested_searchable do
        mapper.resources :search,
                         path: :search,
                         only: :index
      end
    end
  end
end

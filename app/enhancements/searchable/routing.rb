# frozen_string_literal: true

module Searchable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :searchable do
        mapper.get :search,
                   to: 'search#index',
                   on: :collection
      end
    end
  end
end

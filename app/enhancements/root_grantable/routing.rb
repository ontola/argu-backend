# frozen_string_literal: true

module RootGrantable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :root_grantable do
        mapper.resources :grants, only: :index
      end
    end
  end
end

# frozen_string_literal: true

module Grantable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :grantable do
        mapper.resource :grant_tree, only: %i[show], path: 'permissions'
      end
    end
  end
end

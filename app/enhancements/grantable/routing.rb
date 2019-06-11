# frozen_string_literal: true

module Grantable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :grantable do
        mapper.resource :grant_tree, only: %i[show], path: 'permissions'
        mapper.resources :granted_groups, only: %i[index], path: 'granted'
      end
    end
  end
end

# frozen_string_literal: true

module Settingable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :settingable do
        mapper.get :settings, on: :member
        mapper.get 'settings/menus', to: 'sub_menus#index', menu_id: 'settings'
      end
    end
  end
end

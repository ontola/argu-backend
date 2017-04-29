# frozen_string_literal: true
module Service
  module Create
    extend ActiveSupport::Concern

    included do
      define_action_methods(:create)
    end
  end
end

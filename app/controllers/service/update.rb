# frozen_string_literal: true
module Service
  module Update
    extend ActiveSupport::Concern

    included do
      define_action_methods(:update)
    end
  end
end

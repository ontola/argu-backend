# frozen_string_literal: true

module Service
  module Destroy
    extend ActiveSupport::Concern

    included do
      define_action_methods(:destroy)
    end
  end
end

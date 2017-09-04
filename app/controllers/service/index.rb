# frozen_string_literal: true

module Service
  module Index
    extend ActiveSupport::Concern

    included do
      define_handlers(:index)
    end
  end
end

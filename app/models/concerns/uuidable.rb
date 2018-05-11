# frozen_string_literal: true

module Uuidable
  extend ActiveSupport::Concern

  included do
    def initialize(opts = {})
      opts[:uuid] ||= SecureRandom.uuid
      super
    end
  end
end

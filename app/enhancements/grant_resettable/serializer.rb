# frozen_string_literal: true

module GrantResettable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_many :grant_resets, if: method(:never)
    end
  end
end

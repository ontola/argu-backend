# frozen_string_literal: true

module Feedable
  module Policy
    extend ActiveSupport::Concern

    def feed?
      show?
    end
  end
end

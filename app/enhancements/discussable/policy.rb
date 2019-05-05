# frozen_string_literal: true

module Discussable
  module Policy
    extend ActiveSupport::Concern

    def index_children?(raw_klass)
      return show? if raw_klass.to_sym == :discussions

      super
    end
  end
end

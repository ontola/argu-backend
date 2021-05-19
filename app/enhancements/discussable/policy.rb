# frozen_string_literal: true

module Discussable
  module Policy
    extend ActiveSupport::Concern

    def index_children?(raw_klass, opts = {})
      return show? if raw_klass == Discussion

      super
    end
  end
end

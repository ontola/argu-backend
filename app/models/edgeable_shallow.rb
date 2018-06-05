# frozen_string_literal: true

# Implements the basic edgeable interface without actually persisting any data.
module EdgeableShallow
  extend ActiveSupport::Concern

  included do
    def owner
      self
    end

    def root_object?
      false
    end

    def respond_to?(method)
      return false if method == :edge
      super
    end

    private

    def remove_edge
      self.edge = nil
    end
  end

  module ClassMethods
    def counter_cache_options
      nil
    end
  end
end

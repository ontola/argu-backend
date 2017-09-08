# frozen_string_literal: true

# Implements the basic edgeable interface without actually persisting any data.
module Edgeable
  module Shallow
    extend ActiveSupport::Concern

    included do
      attr_reader :edge

      has_one :edge,
              as: :owner,
              inverse_of: :owner,
              required: false

      before_validation :remove_edge

      def edge
        @edge ||= Edge.new(parent: shallow_parent, owner: self)
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
end

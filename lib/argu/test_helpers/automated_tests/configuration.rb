# frozen_string_literal: true
module Argu
  module TestHelpers
    module AutomatedTests
      def self.configure
        yield @config ||= AutomatedTests::Configuration.new
      end

      def self.config
        @config
      end

      class Configuration #:nodoc:
        include ActiveSupport::Configurable
        config_accessor :action_methods, :user_types
      end
    end
  end
end

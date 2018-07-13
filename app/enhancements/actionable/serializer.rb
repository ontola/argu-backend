# frozen_string_literal: true

module Actionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      include_actions
    end

    module ClassMethods
      def include_actions
        has_many :actions,
                 key: :operation,
                 unless: :system_scope?,
                 predicate: NS::SCHEMA[:potentialAction],
                 graph: NS::LL[:add] do
          object.actions(scope) if scope.is_a?(UserContext)
        end
        define_action_methods
      end

      def define_action_methods
        actions_class.defined_actions.each do |action|
          method_name = "#{action}_action"
          define_method method_name do
            object.action(scope, action) if scope.is_a?(UserContext)
          end

          has_one method_name,
                  predicate: NS::ARGU[method_name.camelize(:lower)],
                  unless: :system_scope?
        end
      end

      def actions_class
        name.gsub('Serializer', '').constantize.actions_class!
      end
    end
  end
end

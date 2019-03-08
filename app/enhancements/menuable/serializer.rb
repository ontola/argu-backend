# frozen_string_literal: true

module Menuable
  module Serializer
    extend ActiveSupport::Concern

    included do
      include_menus
    end

    module ClassMethods
      def inherited(target)
        target.include_menus
        super
      end

      def include_menus # rubocop:disable Metrics/AbcSize
        return if name.blank?

        "#{name.gsub('Serializer', '')}MenuList".constantize.defined_menus.each do |menu|
          method_name = "#{menu}_menu"
          define_method method_name do
            object.menu(scope, menu) if scope.is_a?(UserContext)
          end

          has_one method_name, predicate: NS::ARGU["#{menu.to_s.camelize(:lower)}Menu"], unless: :system_scope?
        end
      end
    end
  end
end

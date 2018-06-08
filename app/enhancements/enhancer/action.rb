# frozen_string_literal: true

module Enhancer
  module Action
    class << self
      def enhance(klass, enhancement)
        klass.actions_class!.include enhancement
      end
    end

    module Enhanceable
      extend ActiveSupport::Concern

      module ClassMethods
        def actions_class!
          actions_class || define_actions_class
        end

        private

        def actions_class
          "::Actions::#{name}Actions".safe_constantize
        end

        def action_superclass
          "::Actions::#{superclass.name}Actions".safe_constantize || ::Actions::Base
        end

        def define_actions_class
          ::Actions.const_set("#{name}Actions", Class.new(action_superclass))
        end
      end
    end
  end
end

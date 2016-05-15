module Argu
  module Testing
    module ObjectDefinitions
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        COMMON_OBJECTS = [
          [:freetown, :forum, {name: 'freetown'}],
          [:user, :user],
          [:staff, :user, :staff],
          [:member, definition_type: :role],
          [:manager, definition_type: :role],
          [:owner, definition_type: :role],
          [:page, :page],
          [:motion, :motion, forum: :freetown],
          [:question, :question, forum: :freetown]
        ].freeze

        def common_definitions
          COMMON_OBJECTS
        end
      end
    end
  end
end

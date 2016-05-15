module Argu
  module Testing
    module Defaults
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods
        def default_cascaded_method
          :freetown
        end
      end

      module ClassMethods
        COMMON_OBJECTS = [
          [:forum, :forum],
          [:freetown, :forum, {name: 'freetown'}],
          [:user, :user],
          [:staff, :user, :staff],
          [:member, definition_type: :role],
          [:manager, definition_type: :role],
          [:owner, definition_type: :role],
          [:page, :page],
          [:motion, :motion, forum: :freetown],
          [:question, :question, forum: :freetown],
          [:argument, :argument, forum: :freetown],
          [:comment, :comment, forum: :freetown]
        ].freeze

        def common_definitions
          COMMON_OBJECTS
        end
      end
    end
  end
end

# frozen_string_literal: true

module Menuable
  module Model
    extend ActiveSupport::Concern

    included do
      def menus(user_context)
        @menus ||= "#{self.class}MenuList"
                     .constantize
                     .new(resource: self, user_context: user_context)
                     .menus
      end

      def menu(user_context, tag)
        menus(user_context).find { |menu| menu.tag == tag } ||
          raise("Menu '#{tag}' not available for #{self.class.name}")
      end
    end
  end
end

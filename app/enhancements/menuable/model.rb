# frozen_string_literal: true

module Menuable
  module Model
    extend ActiveSupport::Concern

    included do
      def menus(user_context)
        @menus ||= self.class.menu_class
                     .new(resource: self, user_context: user_context)
                     .menus
      end

      def menu(user_context, tag)
        menus(user_context).find { |menu| menu.tag == tag } ||
          raise("Menu '#{tag}' not avadilable for #{self.class.name}")
      end
    end

    module ClassMethods
      def menu_class
        @menu_class ||= "#{name}MenuList".safe_constantize || "#{superclass.name}MenuList".safe_constantize
      end
    end
  end
end

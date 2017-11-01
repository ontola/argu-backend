# frozen_string_literal: true

module Menuable
  extend ActiveSupport::Concern

  included do
    def menus(user_context)
      @menus ||= "#{self.class}MenuList"
                   .constantize
                   .new(resource: self, user_context: user_context)
                   .menus
    end

    def menu(user_context, tag)
      menus(user_context).find { |menu| menu.tag == tag } || raise("Menu '#{tag}' not available for #{self.class.name}")
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    module ClassMethods
      def include_menus
        "#{name.gsub('Serializer', '')}MenuList".constantize.defined_menus.each do |menu|
          method_name = "#{menu}_menu"
          define_method method_name do
            object.menu(scope, menu) if scope.is_a?(UserContext)
          end

          has_many method_name, predicate: RDF::ARGU["#{menu.to_s.camelize(:lower)}Menu"]
        end
      end
    end
  end
end

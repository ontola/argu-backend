# frozen_string_literal: true

module VirtualAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :virtual_attributes

    private

    def initialize_virtual_attributes
      self.class.virtual_attributes&.each(&method(:initialize_virtual_attribute))
    end

    def initialize_virtual_attribute(virtual_attribute)
      sync_virtual_attribute(virtual_attribute)
      clear_attribute_change(virtual_attribute)
    end

    def sync_virtual_attribute(virtual_attribute)
      self[virtual_attribute] = send("#{virtual_attribute}_reader")
    end
  end

  module ClassMethods
    private

    def virtual_attribute(name, type = Type::Value.new, opts = {})
      self.virtual_attributes ||= []
      self.virtual_attributes << name
      virtual_attribute_reader(name, opts.delete(:value))
      virtual_attribute_dependence(name, opts.delete(:dependent_on)) if opts[:dependent_on]
      attribute name, type, opts
    end

    def virtual_attribute_dependence(name, dependent_on)
      define_method("#{dependent_on}=") do |val|
        result = super(val)
        sync_virtual_attribute(name)
        send("#{name}_will_change!") unless attributes[name] == send(name)
        result
      end
    end

    def virtual_attribute_reader(name, value)
      define_method "#{name}_reader" do
        value.call(self)
      end
    end
  end
end

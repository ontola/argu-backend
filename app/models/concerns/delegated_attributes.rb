# frozen_string_literal: true

module DelegatedAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :delegated_attributes

    def self.class_for_delegated_attribute(name)
      delegated_attributes[name].to_s.classify.safe_constantize
    end

    def self.is_delegated_attribute?(attr)
      delegated_attributes.key?(attr)
    end

    def self.delegated_attribute(attr, type, **opts)
      self.delegated_attributes ||= {}
      to = opts.delete(:to)
      self.delegated_attributes[attr.to_s] = to.to_s
      virtual_attribute attr, type, value: ->(r) { r.send(to)&.send(attr) }
    end
  end
end

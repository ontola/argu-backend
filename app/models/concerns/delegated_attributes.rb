# frozen_string_literal: true

module DelegatedAttributes
  extend ActiveSupport::Concern

  included do
    def self.delegated_attribute(attr, type, opts = {})
      attribute attr, type, opts.except(:default, :to)
      define_method attr do
        attributes[attr.to_s] || send(opts[:to])&.send(attr) || opts[:default]
      end
    end
  end
end

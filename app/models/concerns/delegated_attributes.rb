# frozen_string_literal: true

module DelegatedAttributes
  extend ActiveSupport::Concern

  included do
    def self.delegated_attribute(attr, type, opts = {})
      to = opts.delete(:to)
      virtual_attribute attr, type, value: ->(r) { r.send(to)&.send(attr) }
    end
  end
end

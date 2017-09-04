# frozen_string_literal: true

class ActionSerializer < BaseSerializer
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:context_type)

  attributes :target, :name
end

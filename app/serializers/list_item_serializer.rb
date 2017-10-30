# frozen_string_literal: true

class ListItemSerializer < BaseSerializer
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:resource_type)
end

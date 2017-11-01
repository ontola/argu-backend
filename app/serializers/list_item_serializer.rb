# frozen_string_literal: true

class ListItemSerializer < BaseSerializer
  def type
    RDF::URI.new object.resource_type
  end
end

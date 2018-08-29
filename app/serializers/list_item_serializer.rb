# frozen_string_literal: true

class ListItemSerializer < BaseSerializer
  def type
    RDF::DynamicURI(object.item_type)
  end
end

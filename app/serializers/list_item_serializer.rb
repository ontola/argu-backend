# frozen_string_literal: true

class ListItemSerializer < BaseSerializer
  def type
    RDF::DynamicURI.intern(object.item_type)
  end
end

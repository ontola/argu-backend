# frozen_string_literal: true

class ListItemSerializer < BaseSerializer
  def type
    RDF::URI(object.item_type)
  end
end

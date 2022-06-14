# frozen_string_literal: true

module Menus
  class ItemSerializer < LinkedRails::Menus::ItemSerializer
    attribute :description, predicate: NS.schema.text
  end
end

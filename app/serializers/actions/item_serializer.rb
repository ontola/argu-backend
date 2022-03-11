# frozen_string_literal: true

module Actions
  class ItemSerializer < LinkedRails::Actions::ItemSerializer
    attribute :svg, predicate: NS.ontola[:svg]
  end
end

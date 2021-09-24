# frozen_string_literal: true

class ContainerNodeSerializer < EdgeSerializer
  has_one :parent, predicate: NS.schema.isPartOf, &:parent

  attribute :follows_count, predicate: NS.argu[:followsCount]
  attribute :hide_header, predicate: NS.ontola[:hideHeader]
end

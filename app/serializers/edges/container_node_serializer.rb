# frozen_string_literal: true

class ContainerNodeSerializer < EdgeSerializer
  has_one :parent, predicate: NS::SCHEMA[:isPartOf], &:parent

  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :hide_header, predicate: NS::ONTOLA[:hideHeader]
end

# frozen_string_literal: true

class EdgeSerializer < RecordSerializer
  has_one :parent, key: :partOf, predicate: NS::SCHEMA[:isPartOf]
  has_one :organization, predicate: NS::SCHEMA[:organization] do
    object.ancestor(:page)
  end
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.profileable
  end

  attribute :expires_at, predicate: NS::ARGU[:expiresAt]

  delegate :is_publishable?, to: :object

  triples :children_counts

  def children_counts
    object.children_counts.map do |key, count|
      [
        object.iri,
        NS::ARGU["#{key.camelcase(:lower)}Count".to_sym],
        count.to_i
      ]
    end
  end
end

# frozen_string_literal: true

class EdgeSerializer < RecordSerializer
  has_one :parent, key: :partOf, predicate: NS::SCHEMA[:isPartOf]
  has_one :organization, predicate: NS::SCHEMA[:organization] do
    object.root
  end
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.profileable
  end

  attribute :expires_at, predicate: NS::ARGU[:expiresAt]
  attribute :last_activity_at, predicate: NS::ARGU[:lastActivityAt]
  attribute :pinned_at, predicate: NS::ARGU[:pinnedAt]

  delegate :is_publishable?, to: :object

  def self.count_attribute(type)
    attribute "#{type}_count", predicate: NS::ARGU["#{type.to_s.camelcase(:lower)}Count".to_sym] do
      object.children_count(type)
    end
  end
end

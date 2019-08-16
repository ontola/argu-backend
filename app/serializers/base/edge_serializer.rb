# frozen_string_literal: true

class EdgeSerializer < RecordSerializer
  has_one :parent, key: :partOf, predicate: NS::SCHEMA[:isPartOf]
  has_one :organization, predicate: NS::SCHEMA[:organization] do
    object.root
  end
  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.profileable
  end
  attribute :granted_groups, predicate: NS::ARGU[:grantedGroups], unless: :system_scope?

  attribute :expires_at, predicate: NS::ARGU[:expiresAt]
  attribute :last_activity_at, predicate: NS::ARGU[:lastActivityAt]
  attribute :pinned_at, predicate: NS::ARGU[:pinnedAt]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]

  delegate :is_publishable?, to: :object

  def self.count_attribute(type, opts = {})
    attribute "#{type}_count", {predicate: NS::ARGU["#{type.to_s.camelcase(:lower)}Count".to_sym]}.merge(opts)

    define_method "#{type}_count" do
      object.children_count(type)
    end
  end

  def granted_groups
    RDF::DynamicURI("#{object.iri}/granted")
  end

  def parent
    return object.parent unless object.parent.is_a?(Page) && object.parent_collections.count == 1

    object.parent_collections.first
  end
end

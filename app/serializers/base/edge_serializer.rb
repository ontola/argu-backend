# frozen_string_literal: true

class EdgeSerializer < RecordSerializer
  has_one :parent, predicate: NS::SCHEMA[:isPartOf] do |object, opts|
    if object.parent.is_a?(Page) && object.parent_collections(opts[:scope]).count == 1
      object.parent_collections(opts[:scope]).first
    else
      object.parent
    end
  end
  has_one :organization, predicate: NS::ONTOLA[:organization], &:root
  has_one :creator,
          predicate: NS::SCHEMA[:creator] do |object|
    object.creator.profileable
  end
  attribute :granted_groups, predicate: NS::ARGU[:grantedGroups], unless: method(:system_scope?) do |object|
    RDF::URI("#{object.iri}/granted")
  end

  attribute :expires_at, predicate: NS::ARGU[:expiresAt]
  attribute :last_activity_at, predicate: NS::ARGU[:lastActivityAt]
  attribute :pinned_at, predicate: NS::ARGU[:pinnedAt]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]

  delegate :is_publishable?, to: :object

  def self.count_attribute(type, opts = {})
    attribute "#{type}_count",
              {predicate: NS::ARGU["#{type.to_s.camelcase(:lower)}Count".to_sym]}.merge(opts) do |object, params|
      block_given? ? yield(object, params) : object.children_count(type)
    end
  end
end

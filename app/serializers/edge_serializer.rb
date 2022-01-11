# frozen_string_literal: true

class EdgeSerializer < RecordSerializer
  include Edgeable::Properties::Serializer

  has_one :parent, predicate: NS.schema.isPartOf do |object, opts|
    if object.parent.is_a?(Page) && object.parent_collections(opts[:scope]).count == 1
      object.parent_collections(opts[:scope]).reject { |c| c.is_a?(SearchResult::Collection) }.first
    else
      object.parent
    end
  end
  has_one :creator,
          predicate: NS.schema.creator do |object|
    object.creator&.profileable
  end
  attribute :granted_groups, predicate: NS.argu[:grantedGroups], unless: method(:system_scope?) do |object|
    base_iri = object.persisted? ? object.iri : object.try(:persisted_edge)&.iri

    RDF::URI("#{base_iri}/granted") if base_iri
  end
  attribute :is_trashed,
            predicate: NS.argu[:trashed],
            datatype: NS.xsd.boolean
  attribute :is_draft,
            predicate: NS.argu[:isDraft],
            datatype: NS.xsd.boolean

  attribute :expires_at, predicate: NS.argu[:expiresAt]
  attribute :last_activity_at, predicate: NS.argu[:lastActivityAt]
  attribute :pinned_at, predicate: NS.argu[:pinnedAt]
  attribute :pinned, predicate: NS.argu[:pinned], datatype: NS.xsd.boolean
  attribute :url, predicate: NS.argu[:shortname], datatype: NS.xsd.string
end

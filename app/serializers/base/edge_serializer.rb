# frozen_string_literal: true

class EdgeSerializer < RecordSerializer
  include Edgeable::Properties::Serializer

  has_one :parent, predicate: NS::SCHEMA[:isPartOf] do |object, opts|
    if object.parent.is_a?(Page) && object.parent_collections(opts[:scope]).count == 1
      object.parent_collections(opts[:scope]).first
    else
      object.parent
    end
  end
  has_one :creator,
          predicate: NS::SCHEMA[:creator] do |object|
    object.creator&.profileable
  end
  attribute :granted_groups, predicate: NS::ARGU[:grantedGroups], unless: method(:system_scope?) do |object|
    base_iri = object.persisted? ? object.iri : object.try(:persisted_edge)&.iri

    RDF::URI("#{base_iri}/granted") if base_iri
  end
  attribute :is_trashed,
            predicate: NS::ARGU[:trashed],
            datatype: NS::XSD[:boolean]
  attribute :is_draft,
            predicate: NS::ARGU[:isDraft],
            datatype: NS::XSD[:boolean]

  attribute :expires_at, predicate: NS::ARGU[:expiresAt]
  attribute :last_activity_at, predicate: NS::ARGU[:lastActivityAt]
  attribute :pinned_at, predicate: NS::ARGU[:pinnedAt]
  attribute :pinned, predicate: NS::ARGU[:pinned], datatype: NS::XSD[:boolean]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
end

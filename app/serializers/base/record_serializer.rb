# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :iri
  attribute :created_at, predicate: NS.schema.dateCreated
  attribute :published_at, predicate: NS.schema.datePublished do |object|
    object.is_publishable? ? object.published_at : object.created_at
  end
  attribute :display_name, predicate: NS.schema.name
  attribute :_destroy, predicate: NS.ontola[:_destroy], if: method(:never)
  attribute :organization, predicate: NS.ontola[:organization] do
    ActsAsTenant.current_tenant.try(:iri)
  end
end

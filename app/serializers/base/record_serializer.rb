# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :created_at, predicate: RDF::SCHEMA[:dateCreated]
  attribute :updated_at, predicate: RDF::SCHEMA[:dateModified]
  attribute :display_name, predicate: RDF::SCHEMA[:name]
end

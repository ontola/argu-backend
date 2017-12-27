# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :iri
  attribute :created_at, predicate: NS::SCHEMA[:dateCreated]
  attribute :updated_at, predicate: NS::SCHEMA[:dateModified]
  attribute :display_name, predicate: NS::SCHEMA[:name]

  def export?
    scope&.doorkeeper_scopes&.include? 'export'
  end
end

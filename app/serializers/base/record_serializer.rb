# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :iri
  attribute :created_at, predicate: NS::SCHEMA[:dateCreated]
  attribute :published_at, predicate: NS::SCHEMA[:datePublished]
  attribute :display_name, predicate: NS::SCHEMA[:name], graph: NS::LL[:add]
  attribute :_destroy, predicate: NS::ONTOLA[:_destroy]

  def export?
    scope&.doorkeeper_scopes&.include? 'export'
  end

  def published_at
    object.is_publishable? ? object.published_at : object.created_at
  end
end

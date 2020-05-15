# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :iri
  attribute :created_at, predicate: NS::SCHEMA[:dateCreated]
  attribute :published_at, predicate: NS::SCHEMA[:datePublished] do |object|
    object.is_publishable? ? object.published_at : object.created_at
  end
  attribute :display_name, predicate: NS::SCHEMA[:name]
  attribute :_destroy, predicate: NS::ONTOLA[:_destroy], if: method(:never)
end

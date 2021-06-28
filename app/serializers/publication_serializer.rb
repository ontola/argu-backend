# frozen_string_literal: true

class PublicationSerializer < BaseSerializer
  attribute :draft, predicate: NS.argu[:draft]
  attribute :published_at, predicate: NS.schema.datePublished
end

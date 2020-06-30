# frozen_string_literal: true

class PublicationSerializer < BaseSerializer
  attribute :draft, predicate: NS::ARGU[:draft]
  attribute :published_at, predicate: NS::SCHEMA[:datePublished]
end

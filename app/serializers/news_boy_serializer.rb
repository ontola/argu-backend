# frozen_string_literal: true

class NewsBoySerializer < BaseSerializer
  attribute :title, predicate: RDF::SCHEMA[:name]
  attribute :content, predicate: RDF::SCHEMA[:text]
  attribute :audience, predicate: RDF::ARGU[:audience]
  attribute :sample_size, predicate: RDF::ARGU[:sampleSize]
  attribute :dismissable, predicate: RDF::ARGU[:dismissable]
  attribute :published_at, predicate: RDF::ARGU[:publishedAt]
  attribute :ends_at, predicate: RDF::ARGU[:endsAt]
end

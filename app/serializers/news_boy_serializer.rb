# frozen_string_literal: true

class NewsBoySerializer < BaseSerializer
  attribute :title, predicate: NS::SCHEMA[:name]
  attribute :content, predicate: NS::SCHEMA[:text]
  attribute :audience, predicate: NS::ARGU[:audience]
  attribute :sample_size, predicate: NS::ARGU[:sampleSize]
  attribute :dismissable, predicate: NS::ARGU[:dismissable]
  attribute :published_at, predicate: NS::ARGU[:publishedAt]
  attribute :ends_at, predicate: NS::ARGU[:endsAt]
end

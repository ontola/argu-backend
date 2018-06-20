# frozen_string_literal: true

FactoryBot.define do
  factory :vote_match do
    name { |n| "vote_match_#{n}" }
    voteables [
      {item_type: NS::ARGU[:Motion], item_iri: 'https://example.com/1'},
      {item_type: NS::ARGU[:Motion], item_iri: 'https://example.com/2'}
    ]
  end
end

# frozen_string_literal: true
FactoryGirl.define do
  factory :vote_match do
    name { |n| "vote_match_#{n}" }
    voteables [
      {resource_type: 'argu:Motion', iri: 'https://example.com/1'},
      {resource_type: 'argu:Motion', iri: 'https://example.com/2'}
    ]
  end
end

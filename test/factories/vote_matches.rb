# frozen_string_literal: true
FactoryGirl.define do
  factory :vote_match do
    name { |n| "vote_match_#{n}" }
  end
end

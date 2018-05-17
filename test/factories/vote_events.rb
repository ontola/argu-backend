# frozen_string_literal: true

FactoryGirl.define do
  factory :vote_event do
    association :forum
    starts_at 1.day.ago
  end
end

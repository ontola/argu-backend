# frozen_string_literal: true

FactoryGirl.define do
  factory :comment do
    sequence(:body) { |i| "fg comment body #{i}end" }
  end
end

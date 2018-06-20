# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    sequence(:body) { |i| "fg comment body #{i}end" }
  end
end

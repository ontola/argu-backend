# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    sequence(:title) { |n| "fg topic title #{n}end" }
    sequence(:content) { |i| "fg topic content #{i}end" }
  end
end

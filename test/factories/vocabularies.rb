# frozen_string_literal: true

FactoryBot.define do
  factory :vocabulary do
    sequence(:title) { |n| "fg vocabulary title #{n}end" }
    sequence(:content) { |i| "fg vocabulary content #{i}end" }
    sequence(:url) { |i| "vocab#{i}" }
  end
end

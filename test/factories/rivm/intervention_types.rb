# frozen_string_literal: true

FactoryBot.define do
  factory :intervention_type do
    sequence(:title) { |n| "fg risk title #{n}end" }
    sequence(:content) { |i| "fg risk content #{i}end" }
  end
end

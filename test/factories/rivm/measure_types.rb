# frozen_string_literal: true

FactoryBot.define do
  factory :measure_type do
    sequence(:title) { |n| "fg measure type title #{n}end" }
    sequence(:content) { |i| "fg measure type content #{i}end" }
  end
end

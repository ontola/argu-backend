# frozen_string_literal: true

FactoryBot.define do
  factory :survey do
    sequence(:title) { |n| "fg survey title #{n}end" }
    sequence(:content) { |i| "fg survey content #{i}end" }
  end
end

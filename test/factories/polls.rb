# frozen_string_literal: true

FactoryBot.define do
  factory :poll do
    sequence(:title) { |n| "fg poll title #{n}end" }
    sequence(:content) { |i| "fg poll content #{i}end" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :motion do
    sequence(:title) { |n| "fg motion title #{n}end" }
    sequence(:content) { |i| "fg motion content #{i}end" }
  end
end

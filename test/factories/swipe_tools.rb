# frozen_string_literal: true

FactoryBot.define do
  factory :swipe_tool do
    sequence(:title) { |n| "fg swipe_tool title #{n}end" }
    sequence(:content) { |i| "fg swipe_tool content #{i}end" }
  end
end

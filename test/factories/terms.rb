# frozen_string_literal: true

FactoryBot.define do
  factory :term do
    sequence(:title) { |n| "fg term #{n}end" }
    sequence(:content) { |i| "fg term content #{i}end" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :budget_shop do
    sequence(:title) { |n| "fg budget title #{n}end" }
    sequence(:content) { |i| "fg budget content #{i}end" }
    budget_max { 1000 }
  end
end

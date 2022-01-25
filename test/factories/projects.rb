# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    sequence(:title) { |n| "fg project title #{n}end" }
    sequence(:content) { |i| "fg project content #{i}end" }
  end
end

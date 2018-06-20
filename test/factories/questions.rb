# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    association :forum, strategy: :create
    sequence(:title) { |n| "fg question title #{n}end" }
    sequence(:content) { |n| "fg question content #{n}end" }
  end
end

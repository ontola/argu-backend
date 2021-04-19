# frozen_string_literal: true

FactoryBot.define do
  factory :measure do
    sequence(:title) { |n| "fg measure type title #{n}end" }
    sequence(:content) { |i| "fg measure type content #{i}end" }
    comments_allowed { :comments_are_allowed }
  end
end

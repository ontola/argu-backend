# frozen_string_literal: true

FactoryBot.define do
  factory :intervention_type do
    sequence(:title) { |n| "fg intervention type title #{n}end" }
    sequence(:content) { |i| "fg intervention type content #{i}end" }
  end
end

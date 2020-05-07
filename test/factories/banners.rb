# frozen_string_literal: true

FactoryBot.define do
  factory :banner do
    sequence(:content) { |n| "Banner content #{n}" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :favorite do
    association :user
  end
end

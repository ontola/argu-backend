# frozen_string_literal: true

FactoryBot.define do
  factory :email_address do
    sequence :email do |n|
      "email#{n}@example.com"
    end
  end
end

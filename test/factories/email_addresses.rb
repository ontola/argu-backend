# frozen_string_literal: true

FactoryGirl.define do
  factory :email_address do
    sequence :email do |n|
      "email#{n}@example.com"
    end
  end
end

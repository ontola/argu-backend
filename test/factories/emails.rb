# frozen_string_literal: true
FactoryGirl.define do
  factory :email do
    sequence :email do |n|
      "email#{n}@example.com"
    end
  end
end

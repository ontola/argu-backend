# frozen_string_literal: true

FactoryGirl.define do
  factory :favorite do
    association :user
  end
end

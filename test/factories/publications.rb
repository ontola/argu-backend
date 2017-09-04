# frozen_string_literal: true

FactoryGirl.define do
  factory :publication do
    association :creator, factory: :profile
    published_at DateTime.current
    channel 'argu'
  end
end

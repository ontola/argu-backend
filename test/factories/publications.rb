# frozen_string_literal: true

FactoryBot.define do
  factory :publication do
    association :creator, factory: :profile
    published_at { Time.current }
    channel { 'argu' }
  end
end

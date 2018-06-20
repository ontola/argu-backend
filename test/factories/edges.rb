# frozen_string_literal: true

FactoryBot.define do
  factory :edge do
    association :user
    parent do
      passed_in?(:parent) ? parent : owner.parent
    end
  end
end

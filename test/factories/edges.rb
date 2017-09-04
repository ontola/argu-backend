# frozen_string_literal: true

FactoryGirl.define do
  factory :edge do
    association :user
    parent do
      passed_in?(:parent) ? parent : owner.parent_model.edge
    end
  end
end

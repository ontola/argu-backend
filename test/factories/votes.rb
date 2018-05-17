# frozen_string_literal: true

FactoryGirl.define do
  factory :vote do
    add_attribute :for, Vote.fors[:pro]
  end
end

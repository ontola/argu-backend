# frozen_string_literal: true
FactoryGirl.define do
  factory :vote, traits: [:set_publisher] do
    association :forum
    add_attribute :for, Vote.fors[:pro]
    association :voter, factory: :profile, strategy: :create
    creator { voter }
  end
end

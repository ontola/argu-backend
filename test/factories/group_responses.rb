# frozen_string_literal: true
FactoryGirl.define do
  factory :group_response do
    association :forum, strategy: :build
    association :group
    association :motion
    association :creator, factory: :profile
    association :publisher, factory: [:user, :follows_reactions_directly]
    side :pro
    sequence(:text) { |i| "fg group response #{i}end" }
  end
end

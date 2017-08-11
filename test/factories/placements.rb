# frozen_string_literal: true
FactoryGirl.define do
  factory :placement do
    association :place
    association :placeable, factory: :motion
    association :creator, factory: :profile
    association :publisher, factory: :user
    placement_type :custom

    factory :home_placement do
      association :placeable, factory: :user
      placement_type :home
    end
  end
end

# frozen_string_literal: true
FactoryGirl.define do
  factory :group_membership do
    member { passed_in?(:member) ? member : create(:profile) }
  end
end

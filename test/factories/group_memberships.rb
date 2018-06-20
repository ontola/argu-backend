# frozen_string_literal: true

FactoryBot.define do
  factory :group_membership do
    member { passed_in?(:member) ? member : create(:profile) }
    start_date Time.current
  end
end

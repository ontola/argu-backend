FactoryGirl.define do
  factory :group_membership do
    group { passed_in?(:group) ? group : create(:group) }
    member { passed_in?(:member) ? member : create(:profile) }
  end
end

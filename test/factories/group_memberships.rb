FactoryGirl.define do
  factory :group_membership do
    member { passed_in?(:member) ? member : create(:profile) }
  end
end

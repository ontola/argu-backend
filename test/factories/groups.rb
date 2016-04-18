FactoryGirl.define do
  factory :group do
    edge { create(:forum).edge }
    sequence(:name) { |i| "fg_groups#{i}end" }
    name_singular 'Group'
    visibility :hidden
  end
end

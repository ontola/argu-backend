FactoryGirl.define do

  factory :group, traits: [:tenantable] do
    name 'Groups'
    name_singular 'Group'

    factory :group_with_members do

    end
  end
end

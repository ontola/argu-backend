FactoryGirl.define do

  factory :group do
    name 'Groups'
    name_singular 'Group'

    #before(:create) do |group, evaluator|
    #  group.forum = Forum.find_via_shortname(evaluator.forum_name)
    #end

    factory :group_with_members do

    end
  end
end

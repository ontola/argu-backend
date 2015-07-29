FactoryGirl.define do

  factory :motion do
    title 'title'
    content 'content'
    forum Forum.find_via_shortname_nil('utrecht')
    association :creator, factory: :profile
  end
end

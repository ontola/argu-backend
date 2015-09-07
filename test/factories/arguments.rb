FactoryGirl.define do

  factory :argument do
    association :motion
    association :creator, factory: :profile
    pro true
    title 'title'
    content 'argument'
  end
end

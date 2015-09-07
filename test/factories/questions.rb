FactoryGirl.define do

  factory :question do
    association :creator, factory: :profile

    title 'title'
    content 'content'
  end
end

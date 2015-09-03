FactoryGirl.define do

  factory :question do
    association :forum, strategy: :create
    association :creator, factory: :profile

    title 'title'
    content 'content'
  end
end

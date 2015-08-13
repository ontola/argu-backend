FactoryGirl.define do

  factory :motion do
    association :forum, strategy: :create
    association :creator, factory: :profile

    title 'title'
    content 'content'
    is_trashed false
  end
end

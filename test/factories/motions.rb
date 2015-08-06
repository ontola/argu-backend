FactoryGirl.define do

  factory :motion do
    title 'title'
    content 'content'
    transient do
      trashed false
      association :forum, strategy: :create
      association :creator, factory: :profile
    end
  end
end

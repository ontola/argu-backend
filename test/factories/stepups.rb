FactoryGirl.define do

  factory :stepup do
    association :forum, strategy: :create
    association :record, factory: :project
    #association :group
    #association :user
    association :moderator, factory: :user

  end
end

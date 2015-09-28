FactoryGirl.define do

  factory :group_response do
    association :group
    association :forum, strategy: :build
    motion {
      passed_in?(:motion) ? motion : FactoryGirl.create(:motion, forum: forum)
    }
    association :profile, factory: :profile
    association :publisher, factory: :user
  end
end

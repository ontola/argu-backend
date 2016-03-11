FactoryGirl.define do

  factory :group_response do
    association :forum, strategy: :build
    association :group
    motion {
      passed_in?(:motion) ? motion : FactoryGirl.create(:motion,
                                                        forum: forum)
    }
    association :profile, factory: :profile
    association :publisher, factory: :user
    side :pro
    sequence(:text) { |i| "fg group response #{i}"  }
  end
end

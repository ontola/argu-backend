FactoryGirl.define do
  factory :group_response do
    association :forum, strategy: :build
    association :group
    motion{ passed_in?(:motion) ? motion : create(:motion, forum: forum) }
    association :creator, factory: :profile
    association :publisher, factory: [:user, :follows_email]
    side :pro
    sequence(:text) { |i| "fg group response #{i}end" }
  end
end

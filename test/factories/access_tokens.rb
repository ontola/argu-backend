FactoryGirl.define do
  factory :access_token do
    #association item
    association :profile, strategy: :build
  end
end

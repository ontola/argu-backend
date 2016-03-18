FactoryGirl.define do
  factory :notification do
    transient do
      forum nil
    end

    association :user
    activity do
      passed_in?(:activity) ?
        activity :
        create(:activity,
               forum: forum)
    end
  end
end

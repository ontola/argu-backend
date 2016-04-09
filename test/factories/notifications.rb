FactoryGirl.define do
  factory :notification do
    transient do
      forum nil
    end

    association :user
    activity do
      if passed_in?(:activity)
        activity
      else
        create(:activity,
               forum: forum)
      end
    end
  end
end

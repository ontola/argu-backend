FactoryGirl.define do
  factory :shortname do
    sequence(:shortname) { |n| "fg_shortname#{n}end" }

    factory :discussion_shortname do
      forum { passed_in?(:forum) ? forum : build(:forum) }
      owner do
        passed_in?(:owner) ? owner : create(:motion, forum: forum)
      end
    end
  end
end

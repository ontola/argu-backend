# frozen_string_literal: true

FactoryGirl.define do
  factory :shortname do
    sequence(:shortname) { |n| "fg_shortname#{n}end" }

    factory :discussion_shortname do
      forum { passed_in?(:forum) ? forum : build(:forum) }
      owner do
        passed_in?(:owner) ? owner : create(:motion, parent: forum.edge)
      end
    end
  end
end

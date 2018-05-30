# frozen_string_literal: true

FactoryGirl.define do
  factory :shortname do
    sequence(:shortname) { |n| "fg_shortname#{n}end" }

    factory :discussion_shortname do
      owner do
        passed_in?(:owner) ? owner : create(:motion, parent: forum)
      end
    end
  end
end

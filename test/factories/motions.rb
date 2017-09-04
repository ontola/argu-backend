# frozen_string_literal: true

FactoryGirl.define do
  factory :motion do
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end

    sequence(:title) { |n| "fg motion title #{n}end" }
    sequence(:content) { |i| "fg motion content #{i}end" }
  end
end

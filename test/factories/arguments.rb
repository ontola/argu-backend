# frozen_string_literal: true

FactoryGirl.define do
  factory :argument do
    association :forum
    association :motion
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    pro true
    sequence(:title) { |i| "fg argument title #{i}end" }
    sequence(:content) { |i| "fg argument content #{i}end" }
  end
end

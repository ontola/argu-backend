# frozen_string_literal: true
FactoryGirl.define do
  factory :vote_event do
    association :forum
    association :group
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    starts_at 1.day.ago
  end
end

# frozen_string_literal: true

FactoryGirl.define do
  factory :decision do
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
  end
end

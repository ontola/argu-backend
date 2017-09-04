# frozen_string_literal: true

FactoryGirl.define do
  factory :comment, traits: [:set_publisher] do
    association :publisher, factory: [:user, :follows_reactions_directly]
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    sequence(:body) { |i| "fg comment body #{i}end" }
  end
end

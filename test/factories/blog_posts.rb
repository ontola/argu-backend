# frozen_string_literal: true
FactoryGirl.define do
  factory :blog_post do
    association :forum
    association :publisher, factory: [:user, :follows_reactions_directly]
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    association :blog_postable, factory: :project

    sequence(:title) { |n| "fg blog post #{n}end" }
    content 'contents'
  end
end

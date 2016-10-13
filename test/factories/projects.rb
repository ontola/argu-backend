# frozen_string_literal: true
FactoryGirl.define do
  factory :project do
    association :forum, strategy: :create
    association :creator, factory: :profile
    association :publisher, factory: [:user, :follows_reactions_directly]
    start_date 1.day.ago
    sequence(:title) { |n| "title#{n}" }
    content 'content'

    factory :published_project do
      before :create do |project|
        pp = project.create_argu_publication(
          published_at: Time.current,
          creator: project.creator
        )
        pp.commit
      end
    end
  end
end

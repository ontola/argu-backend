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

    after :create do |blog_post|
      Argu::TestHelpers::FactoryGirlHelpers.create_activity_for(blog_post)
      Argu::TestHelpers::FactoryGirlHelpers.create_activity_for(blog_post,
                                                                action: :happened,
                                                                created_at: DateTime.current)
      blog_post.publisher.follow(blog_post.edge)
    end
  end
end

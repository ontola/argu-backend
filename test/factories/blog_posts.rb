FactoryGirl.define do
  factory :blog_post do
    association :forum
    association :creator, factory: :profile
    association :publisher, factory: [:user, :follows_email]
    association :blog_postable, factory: :project

    sequence(:title) { |n| "fg blog post #{n}end" }
    content 'contents'

    after :create do |blog_post|
      create :activity,
             created_at: DateTime.current,
             trackable: blog_post,
             forum: blog_post.forum,
             owner: blog_post.creator,
             key: 'blog_post.happened'
      blog_post.publisher.follow(blog_post.edge)
    end
  end
end

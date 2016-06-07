FactoryGirl.define do
  factory :blog_post do
    association :forum
    association :creator, factory: :profile
    association :publisher, factory: [:user, :follows_reactions_directly]
    association :blog_postable, factory: :project

    sequence(:title) { |n| "fg blog post #{n}end" }
    content 'contents'

    after :create do |blog_post|
      blog_post.create_activity action: :create,
                                recipient: blog_post.parent_model,
                                owner: blog_post.creator,
                                forum: blog_post.forum
      blog_post.create_activity action: :happened,
                                created_at: DateTime.current,
                                recipient: blog_post.parent_model,
                                owner: blog_post.creator,
                                forum: blog_post.forum
      blog_post.publisher.follow(blog_post.edge)
    end
  end
end

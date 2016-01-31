FactoryGirl.define do

  factory :blog_post do
    association :forum
    association :creator, factory: :profile

    sequence(:title) { |n| "fg_blog_post #{n}" }
    content 'contents'
  end
end

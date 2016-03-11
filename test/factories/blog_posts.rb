FactoryGirl.define do

  factory :blog_post do
    association :forum
    association :creator, factory: :profile

    sequence(:title) { |n| "fg blog post #{n}" }
    content 'contents'
  end
end

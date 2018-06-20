# frozen_string_literal: true

FactoryBot.define do
  factory :blog_post do
    association :forum
    sequence(:title) { |n| "fg blog post #{n}end" }
    content 'contents'
    mark_as_important '1'
  end
end

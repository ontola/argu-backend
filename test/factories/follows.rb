# frozen_string_literal: true

FactoryBot.define do
  factory :follow do
    association :follower, factory: %i[user follows_reactions_directly]
    follower_type { 'User' }

    before :create do |f|
      f.followable_type = 'Edge'
    end

    %i[question motion argument comment vote].each do |item|
      trait "t_#{item}".to_sym do
        association :followable, factory: :edge, owner: item
      end
    end

    factory :news_follow do
      follow_type { :news }
    end

    factory :never_follow do
      follow_type { :never }
    end
  end
end

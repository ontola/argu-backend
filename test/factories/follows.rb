FactoryGirl.define do
  factory :follow do
    association :follower, factory: [:user, :follows_reactions_directly]
    follower_type 'User'

    before :create do |f|
      f.followable_type = 'Edge'
    end

    %i(question motion argument comment vote group_response).each do |item|
      trait "t_#{item}".to_sym do
        association :followable, factory: :edge, owner: item
      end
    end

    factory :news_follow do
      follow_type :news
    end
  end
end

FactoryGirl.define do
  factory :follow do
    association :follower, factory: [:user, :follows_email]
    follower_type 'User'

    before :create do |f|
      f.followable_type = 'Ltree::Models::Edge'
    end

    %i(question motion argument comment vote group_response).each do |item|
      trait "t_#{item}".to_sym do
        association :followable, factory: :edge, owner: item
      end
    end
  end
end

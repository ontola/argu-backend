FactoryGirl.define do
  factory :follow do
    association :follower, factory: [:user, :follows_email]

    %i(question motion argument comment vote group_response).each do |item|
      trait "t_#{item}".to_sym do
        association :followable, factory: item
      end
    end
  end
end

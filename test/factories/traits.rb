# frozen_string_literal: true

FactoryBot.define do
  trait :with_follower do
    after :create do |resource|
      create(:follow,
             follower: create(:user, :follows_reactions_directly),
             followable: resource)
    end
  end
end

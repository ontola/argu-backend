# frozen_string_literal: true

FactoryGirl.define do
  trait :set_publisher do
    after :build do |res|
      res.publisher = res.creator.profileable if res.publisher.blank?
    end
  end

  trait :with_follower do
    after :create do |resource|
      create(:follow,
             follower: create(:user, :follows_reactions_directly),
             followable: resource.edge)
    end
  end
end

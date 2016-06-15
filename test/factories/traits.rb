FactoryGirl.define do
  trait :set_publisher do
    after :build do |res|
      res.publisher = res.creator.profileable if res.publisher.blank?
    end
  end

  trait :published do
    is_published true
    argu_publication factory: :publication, strategy: :build
  end

  trait :scheduled do
    is_published false
    argu_publication factory: :publication, strategy: :build
  end

  trait :unpublished do
    is_published false
  end

  trait :trashed do
    is_trashed true
  end

  trait :trashed_at do
    trashed_at DateTime.current
  end

  trait :with_notification do
    after :create do |resource|
      follower = create(:user, :viewed_notifications_hour_ago, :follows_reactions_directly)
      create(:follow, followable: resource.edge, follower: follower)
      create :notification, activity: resource.activities.first, user: follower
    end
  end

  # See {Follow}
  # @note Adds an extra {Notification} on associated resource creation
  trait :with_follower do
    after :create do |resource|
      create(:follow,
             follower: create(:user, :follows_reactions_directly),
             followable: resource.edge)
    end
  end
end

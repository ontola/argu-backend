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

  trait :with_edge do
    after :create do |resource|
      parent = !resource.is_a?(Forum) && resource.parent
      path = parent && parent.edge.path
      path ||= resource.identifier
      create(
        :edge,
        owner: resource,
        user: resource.publisher,
        fragment: resource.identifier,
        parent: parent && parent.edge,
        parent_fragment: parent && parent.identifier,
        path: path)
    end
  end

  # See {Follow}
  # @note Adds an extra {Notification} on associated resource creation
  trait :with_follower do
    after :create do |resource|
      create(:follow,
             follower: create(:user, :follows_email),
             followable: resource.edge)
    end
  end
end

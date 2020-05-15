# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  extend AnalyticsHelper
  include ProfilePhotoable::Serializer

  attribute :a_uuid, predicate: NS::ARGU[:anonymousID] do |object|
    a_uuid(object.user)
  end
  attribute :actor_type, predicate: NS::ONTOLA[:actorType]
  attribute :has_analytics?, predicate: NS::ARGU[:hasAnalytics]
  attribute :shortname
  attribute :url
  attribute :primary_email,
            predicate: NS::ARGU[:primaryEmail]

  has_one :user, predicate: NS::ARGU[:user]
  has_one :actor, predicate: NS::ONTOLA[:actor] do |object|
    object.actor&.profileable
  end
end

# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  include ProfilePhotoable::Serializer

  attribute :actor_type, predicate: NS::ONTOLA[:actorType]
  attribute :has_analytics?, predicate: NS::ARGU[:hasAnalytics]
  attribute :mount_action, predicate: NS::ONTOLA[:mountAction]
  attribute :primary_email, predicate: NS::ARGU[:primaryEmail]
  attribute :user_seq, predicate: RDF[:_0] do |object|
    object&.user&.iri
  end
  attribute :unread_notification_count, predicate: NS::ARGU[:unreadCount]

  has_one :user, predicate: NS::ARGU[:user]
  has_one :actor, predicate: NS::ONTOLA[:actor] do |object|
    object.profile&.profileable
  end
end

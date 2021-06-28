# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  include ProfilePhotoable::Serializer

  attribute :actor_type, predicate: NS.ontola[:actorType]
  attribute :has_analytics?, predicate: NS.argu[:hasAnalytics]
  attribute :mount_action, predicate: NS.ontola[:mountAction]
  attribute :primary_email, predicate: NS.argu[:primaryEmail]
  attribute :user_seq, predicate: RDF[:_0] do |object|
    object&.user&.iri
  end
  attribute :unread_notification_count, predicate: NS.argu[:unreadCount]

  has_one :user, predicate: NS.argu[:user]
  has_one :actor, predicate: NS.ontola[:actor] do |object|
    object.profile&.profileable
  end
end

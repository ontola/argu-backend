# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  include AnalyticsHelper
  include ProfilePhotoable::Serializer

  attribute :a_uuid, predicate: NS::ARGU[:anonymousID]
  attribute :actor_type, predicate: NS::ONTOLA[:actorType], key: :body
  attribute :has_analytics?, predicate: NS::ARGU[:hasAnalytics]
  attribute :shortname
  attribute :url
  attribute :primary_email,
            predicate: NS::ARGU[:primaryEmail]

  has_one :user, predicate: NS::ARGU[:user]
  has_one :actor, predicate: NS::ONTOLA[:actor] do
    object.actor&.profileable
  end

  def a_uuid
    super(object.user)
  end

  def default_profile_photo
    object.user&.default_profile_photo
  end

  def has_analytics?
    object.user.has_analytics?
  end

  def primary_email
    object&.user&.primary_email_record&.email
  end

  def type
    NS::ONTOLA[object.actor_type]
  end
end

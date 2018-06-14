# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  include ProfilePhotoable::Serializer

  attribute :actor_type, predicate: NS::ARGU[:actorType], key: :body
  attribute :shortname
  attribute :url
  attribute :primary_email,
            predicate: NS::ARGU[:primaryEmail],
            if: :afe_request?

  has_one :user, predicate: NS::ARGU[:user]
  has_one :actor, predicate: NS::ARGU[:actor] do
    object.actor&.profileable
  end

  def default_profile_photo
    object.actor&.default_profile_photo
  end

  def primary_email
    object&.user&.primary_email_record&.email
  end

  def type
    NS::ARGU[object.actor_type]
  end
end

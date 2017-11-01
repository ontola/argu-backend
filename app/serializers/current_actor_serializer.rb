# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  attribute :actor_type, predicate: RDF::ARGU[:actorType], key: :body
  attribute :shortname
  attribute :url

  has_one :profile_photo, predicate: RDF::SCHEMA[:image] do
    object.actor&.default_profile_photo
  end
  has_one :user, predicate: RDF::ARGU[:user]
  has_one :actor, predicate: RDF::ARGU[:actor] do
    object.actor&.profileable
  end
end

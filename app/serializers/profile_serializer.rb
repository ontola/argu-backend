# frozen_string_literal: true

class ProfileSerializer < BaseSerializer
  include ProfilePhotoable::Serializer
  attribute :display_name, predicate: NS::SCHEMA[:name]
  attribute :name, predicate: NS::FOAF[:name]
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :are_votes_public, predicate: NS::ARGU[:votesPublic]
  attribute :is_public, predicate: NS::ARGU[:public]
end

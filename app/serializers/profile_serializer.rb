# frozen_string_literal: true

class ProfileSerializer < BaseSerializer
  include ProfilePhotoable::Serializer
  attribute :display_name, predicate: NS::SCHEMA[:name]
end

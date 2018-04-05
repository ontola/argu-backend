# frozen_string_literal: true

class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serializer
  include Voteable::Serializer
  include Commentable::Serializer

  attribute :deku_id, predicate: NS::SCHEMA[:isRelatedTo]
end

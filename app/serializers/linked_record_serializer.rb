# frozen_string_literal: true

class LinkedRecordSerializer < RecordSerializer
  include Voteable::Serializer

  attribute :deku_id, predicate: NS::SCHEMA[:isRelatedTo]
end

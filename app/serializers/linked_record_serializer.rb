# frozen_string_literal: true

class LinkedRecordSerializer < RecordSerializer
  attribute :deku_id, predicate: NS::SCHEMA[:isRelatedTo]
end

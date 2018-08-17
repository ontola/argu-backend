# frozen_string_literal: true

class LinkedRecordSerializer < EdgeSerializer
  attribute :deku_id, predicate: NS::SCHEMA[:isRelatedTo]
end

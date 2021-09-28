# frozen_string_literal: true

class VoteEventSerializer < EdgeSerializer
  attribute :expires_at, predicate: NS.schema.endDate
end

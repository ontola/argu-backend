# frozen_string_literal: true

class TermSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]

  with_collection :edges, predicate: NS::ARGU[:taggings]
end

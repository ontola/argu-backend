# frozen_string_literal: true

class TermSerializer < EdgeSerializer
  with_collection :taggings, predicate: NS.argu[:taggings]
end

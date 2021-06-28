# frozen_string_literal: true

class VocabularySerializer < EdgeSerializer
  with_collection :terms, predicate: NS.argu[:terms]
end

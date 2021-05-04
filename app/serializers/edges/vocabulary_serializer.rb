# frozen_string_literal: true

class VocabularySerializer < EdgeSerializer
  with_collection :terms, predicate: NS::ARGU[:terms]
end

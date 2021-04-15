# frozen_string_literal: true

class VocabularySerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :tagged_label, predicate: NS::ARGU[:taggedLabel]
  with_collection :terms, predicate: NS::ARGU[:terms]
end

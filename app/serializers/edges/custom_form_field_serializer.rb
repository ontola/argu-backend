# frozen_string_literal: true

class CustomFormFieldSerializer < EdgeSerializer
  attribute :sh_path, predicate: NS.sh.path
  attribute :sh_in, predicate: NS.sh.in do |object|
    object.options_vocab&.collection_iri(:terms, page: 1)
  end
end

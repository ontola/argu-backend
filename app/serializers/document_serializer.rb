# frozen_string_literal: true

class DocumentSerializer < BaseSerializer
  attribute :title, predicate: NS.schema.name
  attribute :contents, predicate: NS.schema.text
end

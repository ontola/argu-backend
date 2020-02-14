# frozen_string_literal: true

class DocumentSerializer < BaseSerializer
  attribute :title, predicate: NS::SCHEMA[:name]
  attribute :contents, predicate: NS::SCHEMA[:text]
end

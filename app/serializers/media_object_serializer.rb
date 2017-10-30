# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  delegate :context_type, to: :object
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:context_type)
  attribute :url, predicate: RDF::SCHEMA[:url]
  attribute :thumbnail, predicate: RDF::SCHEMA[:thumbnail]
  attribute :used_as
end

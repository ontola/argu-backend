# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  delegate :context_type, to: :object
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:context_type)
  attributes :url, :thumbnail, :used_as
end

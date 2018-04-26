# frozen_string_literal: true

class ContentEdgeSerializer < EdgeableBaseSerializer
  include Loggable::Serializer
  include Menuable::Serializer

  attribute :content, predicate: NS::SCHEMA[:text]
end

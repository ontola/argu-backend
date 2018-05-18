# frozen_string_literal: true

class ContentEdgeSerializer < EdgeSerializer
  include Menuable::Serializer

  attribute :content, predicate: NS::SCHEMA[:text]
end

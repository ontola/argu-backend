# frozen_string_literal: true

class ContentEdgeSerializer < EdgeSerializer
  include Menuable::Serializer

  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :pinned, predicate: NS::ARGU[:pinned]
end

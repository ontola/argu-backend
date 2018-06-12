# frozen_string_literal: true

class QuestionSerializer < ContentEdgeSerializer
  include Attachable::Serializer
  include BlogPostable::Serializer
  include Photoable::Serializer

  include_menus

  attribute :default_sorting, predicate: NS::ARGU[:defaultSorting]
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
end

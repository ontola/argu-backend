# frozen_string_literal: true

class QuestionSerializer < ContentEdgeSerializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Motionable::Serializer
  include BlogPostable::Serializer
  include Photoable::Serializer
  include_menus

  attribute :default_sorting, predicate: NS::ARGU[:defaultSorting]
  attribute :pinned, predicate: NS::ARGU[:pinned]
  attribute :require_location, predicate: NS::ARGU[:requireLocation]
end

# frozen_string_literal: true

class QuestionSerializer < ContentEdgeSerializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Motionable::Serializer
  include BlogPostable::Serializer
  include_menus
end

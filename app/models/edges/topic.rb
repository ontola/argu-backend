# frozen_string_literal: true

class Topic < Discussion
  include Edgeable::Content

  paginates_per 15
  parentable :container_node
  placeable :custom

  convertible(
    motions: %i[activities media_objects],
    questions: %i[activities media_objects]
  )

  validates :description, presence: true, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {minimum: 4, maximum: 110}

  class << self
    def route_key
      :t
    end
  end
end

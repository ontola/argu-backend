# frozen_string_literal: true

class Topic < Discussion
  include Edgeable::Content

  paginates_per 15
  parentable :container_node
  placeable :custom

  validates :description, presence: true, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {minimum: 5, maximum: 110}
  validates :creator, presence: true
end

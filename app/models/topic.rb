# frozen_string_literal: true

class Topic < Discussion
  include Edgeable::Content

  paginates_per 30
  parentable :container_node
  placeable :custom

  validates :description, presence: true, length: {maximum: 5000}
  validates :display_name, presence: true, length: {minimum: 5, maximum: 110}
  validates :creator, presence: true
end

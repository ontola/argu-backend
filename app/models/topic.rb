# frozen_string_literal: true

class Topic < Edge
  enhance Attachable
  enhance Commentable
  enhance Contactable
  enhance Convertible
  enhance CoverPhotoable
  enhance Exportable
  enhance Feedable
  enhance Inviteable
  enhance MarkAsImportant
  enhance Moveable
  enhance Placeable
  enhance Statable

  include Edgeable::Content

  counter_cache true
  paginates_per 30
  parentable :container_node

  validates :description, presence: true, length: {maximum: 5000}
  validates :display_name, presence: true, length: {minimum: 5, maximum: 110}
  validates :creator, presence: true
end

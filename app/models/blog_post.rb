# frozen_string_literal: true

class BlogPost < Edge
  enhance Attachable
  enhance Commentable
  enhance MarkAsImportant
  enhance CoverPhotoable
  enhance Statable

  include Edgeable::Content
  include HasLinks

  counter_cache true
  parentable :motion, :question, :container_node, :page, :topic, :survey

  validates :description, presence: true, length: {minimum: 2, maximum: 50_000}
  validates :display_name, presence: true, length: {minimum: 2, maximum: 110}
  validates :creator, presence: true
end

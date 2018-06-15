# frozen_string_literal: true

class BlogPost < Edge
  enhance Attachable
  enhance Commentable
  enhance MarkAsImportant
  enhance CoverPhotoable

  include Edgeable::Content
  include HasLinks

  counter_cache true
  parentable :motion, :question, :page

  validates :content, presence: true, length: {minimum: 2}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :creator, presence: true
end

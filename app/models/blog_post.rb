# frozen_string_literal: true

class BlogPost < Edge
  include Edgeable::Content
  enhance Commentable
  enhance MarkAsImportant
  include HasLinks
  include Photoable

  counter_cache true
  parentable :motion, :question, :page

  validates :content, presence: true, length: {minimum: 2}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :creator, presence: true
end

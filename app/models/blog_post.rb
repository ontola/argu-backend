# frozen_string_literal: true

class BlogPost < Edge
  include Edgeable::Content
  concern Commentable
  include ActivePublishable
  include HasLinks

  counter_cache true
  parentable :motion, :question

  validates :content, presence: true, length: {minimum: 2}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :creator, presence: true
end

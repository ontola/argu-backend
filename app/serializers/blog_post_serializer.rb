# frozen_string_literal: true

class BlogPostSerializer < BaseSerializer
  include Commentable::Serializer
  attributes :title, :content

  belongs_to :creator
end

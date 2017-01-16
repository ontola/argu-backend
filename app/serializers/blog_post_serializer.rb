# frozen_string_literal: true
class BlogPostSerializer < BaseSerializer
  include Commentable::Serlializer
  attributes :title, :content

  belongs_to :creator
end

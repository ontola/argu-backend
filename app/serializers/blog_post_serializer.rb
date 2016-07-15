# frozen_string_literal: true
class BlogPostSerializer < BaseSerializer
  attributes :title, :content

  belongs_to :creator
end

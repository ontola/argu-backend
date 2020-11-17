# frozen_string_literal: true

class BlogPostsController < EdgeableController
  private

  def default_publication_follow_type
    return super if parent_resource!.is_a?(Page)

    'news'
  end
end

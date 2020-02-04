# frozen_string_literal: true

class BlogPostsController < EdgeableController
  include BlogPostsHelper
  skip_before_action :check_if_registered, only: :index

  private

  def default_publication_follow_type
    return super if parent_resource!.is_a?(Page)
    'news'
  end
end

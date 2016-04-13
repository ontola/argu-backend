class AddBlogPostsCountToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :blog_posts_count, :integer, default: 0,  null: false
  end
end

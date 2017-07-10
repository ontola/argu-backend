class DropTrashedColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :arguments, :is_trashed
    remove_column :blog_posts, :trashed_at
    remove_column :comments, :is_trashed
    remove_column :motions, :is_trashed
    remove_column :projects, :trashed_at
    remove_column :questions, :is_trashed
  end
end

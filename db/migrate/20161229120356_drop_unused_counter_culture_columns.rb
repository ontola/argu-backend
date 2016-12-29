class DropUnusedCounterCultureColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :arguments, :votes_pro_count
    remove_column :arguments, :comments_count
    remove_column :arguments, :votes_abstain_count
    remove_column :arguments, :votes_con_count
    remove_column :blog_posts, :comments_count
    remove_column :forums, :questions_count
    remove_column :forums, :motions_count
    remove_column :forums, :memberships_count
    remove_column :forums, :projects_count
    remove_column :motions, :votes_pro_count
    remove_column :motions, :votes_con_count
    remove_column :motions, :votes_neutral_count
    remove_column :motions, :argument_pro_count
    remove_column :motions, :argument_con_count
    remove_column :motions, :votes_abstain_count
    remove_column :projects, :questions_count
    remove_column :projects, :motions_count
    remove_column :projects, :phases_count
    remove_column :projects, :blog_posts_count
    remove_column :questions, :motions_count
    remove_column :questions, :votes_pro_count
    remove_column :questions, :votes_con_count
  end
end
